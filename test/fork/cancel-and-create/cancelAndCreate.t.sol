// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ISablierV2Lockup } from "@sablier/v2-core/interfaces/ISablierV2Lockup.sol";
import { Fuzzers } from "@sablier/v2-core-test/utils/Fuzzers.sol";

import { Fork_Test } from "../Fork.t.sol";

contract CancelAndCreate_Fork_Test is Fork_Test, Fuzzers {
    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Runs against deployed dai only.
    constructor() Fork_Test(dai) { }

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function testForkFuzz_CancelAndCreate(uint256 dynamicStreamId, uint256 linearStreamId) external {
        uint256 nextStreamIdDynamic = dynamic.nextStreamId();
        uint256 nextStreamIdLinear = linear.nextStreamId();

        batchCreateWithMilestones();
        batchCreateWithRange();

        // Bound the stream ids so that they are in the range of the ones just created.
        uint256 batchSize = defaults.BATCH_SIZE();
        dynamicStreamId = _bound(dynamicStreamId, nextStreamIdDynamic, nextStreamIdDynamic + batchSize - 1);
        linearStreamId = _bound(linearStreamId, nextStreamIdLinear, nextStreamIdLinear + batchSize - 1);

        expectCancelAndTransferCalls(linear, dynamic, linearStreamId);
        expectCallToCreateWithDeltas({ params: defaults.createWithDeltas() });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithDeltas,
            (
                linear,
                dynamic,
                linearStreamId,
                defaults.createWithDeltas(),
                defaults.permit2Params(defaults.PER_STREAM_AMOUNT())
            )
        );
        bytes memory response = proxy.execute(address(target), data);

        // Assert that the new stream has been created successfully.
        uint256 actualNewStreamId = abi.decode(response, (uint256));
        uint256 expectedNewStreamId = dynamic.nextStreamId() - 1;
        assertEq(actualNewStreamId, expectedNewStreamId, "new stream id mismatch");

        expectCancelAndTransferCalls(dynamic, linear, dynamicStreamId);
        expectCallToCreateWithDurations({ params: defaults.createWithDurations() });

        // ABI encode the parameters and call the function via the proxy.
        data = abi.encodeCall(
            target.cancelAndCreateWithDurations,
            (
                dynamic,
                linear,
                dynamicStreamId,
                defaults.createWithDurations(),
                defaults.permit2Params(defaults.PER_STREAM_AMOUNT())
            )
        );
        response = proxy.execute(address(target), data);

        // Assert that the new stream has been created successfully.
        actualNewStreamId = abi.decode(response, (uint256));
        expectedNewStreamId = linear.nextStreamId() - 1;
        assertEq(actualNewStreamId, expectedNewStreamId, "new stream id mismatch");
    }

    /// @dev Logic shared between all tests.
    function expectCancelAndTransferCalls(
        ISablierV2Lockup cancelContract,
        ISablierV2Lockup createContract,
        uint256 streamId
    )
        internal
    {
        expectCallToCancel(cancelContract, streamId);

        // Asset flow: Sablier → proxy → proxy owner
        // Expect transfers from Sablier to the proxy, and then from the proxy to the proxy owner.
        expectCallToTransfer({ to: address(proxy), amount: defaults.PER_STREAM_AMOUNT() });
        expectCallToTransfer({ to: users.alice.addr, amount: defaults.PER_STREAM_AMOUNT() });

        // Asset flow: proxy owner → proxy → Sablier
        // Expect transfers from the proxy owner to the proxy, and then from the proxy to the Sablier contract.
        expectCallToTransferFrom({ from: users.alice.addr, to: address(proxy), amount: defaults.PER_STREAM_AMOUNT() });
        expectCallToTransferFrom({
            from: address(proxy),
            to: address(createContract),
            amount: defaults.PER_STREAM_AMOUNT()
        });
    }
}
