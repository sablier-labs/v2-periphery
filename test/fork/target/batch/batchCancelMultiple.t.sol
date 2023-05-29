// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Fuzzers } from "@sablier/v2-core-test/utils/Fuzzers.sol";
import { Lockup } from "@sablier/v2-core/types/DataTypes.sol";

import { Batch } from "src/types/DataTypes.sol";

import { Fork_Test } from "../../Fork.t.sol";

contract BatchCancelMultiple_Fork_Test is Fork_Test, Fuzzers {
    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Runs against deployed dai only.
    constructor() Fork_Test(dai) { }

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function test_ForkFuzz_BatchCancelMultiple(
        uint256 batchCancelSize,
        uint256 dynamicBatchFrom,
        uint256 linearBatchFrom
    )
        external
    {
        uint256 nextStreamIdDynamic = dynamic.nextStreamId();
        uint256 nextStreamIdLinear = linear.nextStreamId();

        batchCreateWithMilestones();
        batchCreateWithRange();

        // Bound the variables so that they are in valid range.
        uint256 batchSize = defaults.BATCH_SIZE();
        batchCancelSize = _bound(batchCancelSize, 1, batchSize);
        dynamicBatchFrom =
            _bound(dynamicBatchFrom, nextStreamIdDynamic, nextStreamIdDynamic + batchSize - batchCancelSize);
        linearBatchFrom = _bound(linearBatchFrom, nextStreamIdLinear, nextStreamIdLinear + batchSize - batchCancelSize);

        // Declare the stream ids to cancel.
        uint256[] memory dynamicStreamIds = new uint256[](batchCancelSize);
        uint256[] memory linearStreamIds = new uint256[](batchCancelSize);
        for (uint256 i = 0; i < batchCancelSize; ++i) {
            dynamicStreamIds[i] = dynamicBatchFrom + i;
            linearStreamIds[i] = linearBatchFrom + i;
        }

        // Simulate the passage of time.
        vm.warp({ timestamp: defaults.CLIFF_TIME() });

        // Expects calls to cancel multiple streams.
        expectCallToCancelMultiple({ lockup: dynamic, streamIds: dynamicStreamIds });
        expectCallToCancelMultiple({ lockup: linear, streamIds: linearStreamIds });

        // Asset flow: Sablier → proxy → proxy owner
        // Expects transfers from the Sablier contracts to the proxy, and then from the proxy to the proxy owner.
        expectMultipleCallsToTransfer({
            count: uint64(2 * batchCancelSize),
            to: address(proxy),
            amount: defaults.REFUND_AMOUNT()
        });
        expectCallToTransfer({ to: users.alice.addr, amount: 2 * defaults.REFUND_AMOUNT() * batchCancelSize });

        // ABI encode the parameters and call the function via the proxy.
        Batch.CancelMultiple[] memory batch = new Batch.CancelMultiple[](2);
        batch[0] = Batch.CancelMultiple(dynamic, dynamicStreamIds);
        batch[1] = Batch.CancelMultiple(linear, linearStreamIds);
        bytes memory data = abi.encodeCall(target.batchCancelMultiple, (batch, defaults.assets()));
        proxy.execute(address(target), data);

        // Assert that all streams have been marked as canceled.
        Lockup.Status expectedStatus = Lockup.Status.CANCELED;
        for (uint256 i = 0; i < batchCancelSize; ++i) {
            Lockup.Status actualDynamicStatus = dynamic.statusOf(dynamicStreamIds[i]);
            Lockup.Status actualLinearStatus = linear.statusOf(linearStreamIds[i]);
            assertEq(actualDynamicStatus, expectedStatus, "dynamic stream status not canceled");
            assertEq(actualLinearStatus, expectedStatus, "linear stream status not canceled");
        }
    }
}
