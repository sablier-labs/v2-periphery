// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Defaults } from "../../utils/Defaults.sol";
import { Unit_Test } from "../Unit.t.sol";

/// @dev This contracts tests the following functions:
/// - `cancelAndCreateWithDeltas`
/// - `cancelAndCreateWithDurations`
/// - `cancelAndCreateWithMilestones`
/// - `cancelAndCreateWithRange`
contract CancelAndCreate_Unit_Test is Unit_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                 CREATE WITH DELTAS
    //////////////////////////////////////////////////////////////////////////*/

    function test_CancelAndCreateWithDeltas_SameSablierContract() external {
        // Create the stream due to be canceled.
        uint256 streamId = createWithDeltas();

        // Expect the correct calls to be made.
        expectCancelAndTransferCalls({
            cancelContract: address(dynamic),
            createContract: address(dynamic),
            streamId: streamId
        });
        expectCallToCreateWithDeltas({ params: defaults.createWithDeltas() });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithDeltas,
            (dynamic, dynamic, streamId, defaults.createWithDeltas(), permit2Params(defaults.PER_STREAM_AMOUNT(), 1))
        );
        bytes memory response = proxy.execute(address(target), data);

        // Assert that the new stream has been created successfully.
        uint256 actualNewStreamId = abi.decode(response, (uint256));
        uint256 expectedNewStreamId = dynamic.nextStreamId() - 1;
        assertEq(actualNewStreamId, expectedNewStreamId, "new stream id mismatch");
    }

    function test_CancelAndCreateWithDeltas_AcrossSablierContracts() external {
        // Create the stream due to be canceled.
        uint256 streamId = createWithRange();

        // Expect the correct calls to be made.
        expectCancelAndTransferCalls({
            cancelContract: address(linear),
            createContract: address(dynamic),
            streamId: streamId
        });
        expectCallToCreateWithDeltas({ params: defaults.createWithDeltas() });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithDeltas,
            (linear, dynamic, streamId, defaults.createWithDeltas(), permit2Params(defaults.PER_STREAM_AMOUNT(), 1))
        );
        bytes memory response = proxy.execute(address(target), data);

        // Assert that the new stream has been created successfully.
        uint256 actualNewStreamId = abi.decode(response, (uint256));
        uint256 expectedNewStreamId = dynamic.nextStreamId() - 1;
        assertEq(actualNewStreamId, expectedNewStreamId, "new stream id mismatch");
    }

    /*//////////////////////////////////////////////////////////////////////////
                               CREATE WITH DURATIONS
    //////////////////////////////////////////////////////////////////////////*/

    function test_CancelAndCreateWithDurations_SameSablierContract() external {
        // Create the stream due to be canceled.
        uint256 streamId = createWithDurations();

        // Expect the correct calls to be made.
        expectCancelAndTransferCalls({
            cancelContract: address(linear),
            createContract: address(linear),
            streamId: streamId
        });
        expectCallToCreateWithDurations({ params: defaults.createWithDurations() });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithDurations,
            (linear, linear, streamId, defaults.createWithDurations(), permit2Params(defaults.PER_STREAM_AMOUNT(), 1))
        );
        bytes memory response = proxy.execute(address(target), data);

        // Assert that the new stream has been created successfully.
        uint256 actualNewStreamId = abi.decode(response, (uint256));
        uint256 expectedNewStreamId = linear.nextStreamId() - 1;
        assertEq(actualNewStreamId, expectedNewStreamId, "new stream id mismatch");
    }

    function test_CancelAndCreateWithDurations_AcrossSablierContracts() external {
        // Create the stream due to be canceled.
        uint256 streamId = createWithMilestones();

        // Expect the correct calls to be made.
        expectCancelAndTransferCalls({
            cancelContract: address(dynamic),
            createContract: address(linear),
            streamId: streamId
        });
        expectCallToCreateWithDurations({ params: defaults.createWithDurations() });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithDurations,
            (dynamic, linear, streamId, defaults.createWithDurations(), permit2Params(defaults.PER_STREAM_AMOUNT(), 1))
        );
        bytes memory response = proxy.execute(address(target), data);

        // Assert that the new stream has been created successfully.
        uint256 actualNewStreamId = abi.decode(response, (uint256));
        uint256 expectedNewStreamId = linear.nextStreamId() - 1;
        assertEq(actualNewStreamId, expectedNewStreamId, "new stream id mismatch");
    }

    /*//////////////////////////////////////////////////////////////////////////
                               CREATE WITH MILESTONES
    //////////////////////////////////////////////////////////////////////////*/

    function test_CancelAndCreateWithMilestones_SameSablierContract() external {
        // Create the stream due to be canceled.
        uint256 streamId = createWithMilestones();

        // Expect the correct calls to be made.
        expectCancelAndTransferCalls({
            cancelContract: address(dynamic),
            createContract: address(dynamic),
            streamId: streamId
        });
        expectCallToCreateWithMilestones({ params: defaults.createWithMilestones() });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithMilestones,
            (
                dynamic,
                dynamic,
                streamId,
                defaults.createWithMilestones(),
                permit2Params(defaults.PER_STREAM_AMOUNT(), 1)
            )
        );
        bytes memory response = proxy.execute(address(target), data);

        // Assert that the new stream has been created successfully.
        uint256 actualNewStreamId = abi.decode(response, (uint256));
        uint256 expectedNewStreamId = dynamic.nextStreamId() - 1;
        assertEq(actualNewStreamId, expectedNewStreamId, "new stream id mismatch");
    }

    function test_CancelAndCreateWithMilestones_AcrossSablierContracts() external {
        // Create the stream due to be canceled.
        uint256 streamId = createWithRange();

        // Expect the correct calls to be made.
        expectCancelAndTransferCalls({
            cancelContract: address(linear),
            createContract: address(dynamic),
            streamId: streamId
        });
        expectCallToCreateWithMilestones({ params: defaults.createWithMilestones() });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithMilestones,
            (linear, dynamic, streamId, defaults.createWithMilestones(), permit2Params(defaults.PER_STREAM_AMOUNT(), 1))
        );
        bytes memory response = proxy.execute(address(target), data);

        // Assert that the new stream has been created successfully.
        uint256 actualNewStreamId = abi.decode(response, (uint256));
        uint256 expectedNewStreamId = dynamic.nextStreamId() - 1;
        assertEq(actualNewStreamId, expectedNewStreamId, "new stream id mismatch");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                 CREATE WITH RANGE
    //////////////////////////////////////////////////////////////////////////*/

    function test_CancelAndCreateWithRange_SameSablierContract() external {
        // Create the stream due to be canceled.
        uint256 streamId = createWithRange();

        // Expect the correct calls to be made.
        expectCancelAndTransferCalls({
            cancelContract: address(linear),
            createContract: address(linear),
            streamId: streamId
        });
        expectCallToCreateWithRange({ params: defaults.createWithRange() });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithRange,
            (linear, linear, streamId, defaults.createWithRange(), permit2Params(defaults.PER_STREAM_AMOUNT(), 1))
        );
        bytes memory response = proxy.execute(address(target), data);

        // Assert that the new stream has been created successfully.
        uint256 actualNewStreamId = abi.decode(response, (uint256));
        uint256 expectedNewStreamId = linear.nextStreamId() - 1;
        assertEq(actualNewStreamId, expectedNewStreamId, "new stream id mismatch");
    }

    function test_CancelAndCreateWithRange_AcrossSablierContracts() external {
        // Create the stream due to be canceled.
        uint256 streamId = createWithMilestones();

        // Expect the correct calls to be made.
        expectCancelAndTransferCalls({
            cancelContract: address(dynamic),
            createContract: address(linear),
            streamId: streamId
        });
        expectCallToCreateWithRange({ params: defaults.createWithRange() });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithRange,
            (dynamic, linear, streamId, defaults.createWithRange(), permit2Params(defaults.PER_STREAM_AMOUNT(), 1))
        );
        bytes memory response = proxy.execute(address(target), data);

        // Assert that the new stream has been created successfully.
        uint256 actualNewStreamId = abi.decode(response, (uint256));
        uint256 expectedNewStreamId = linear.nextStreamId() - 1;
        assertEq(actualNewStreamId, expectedNewStreamId, "new stream id mismatch");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Logic shared between all tests.
    function expectCancelAndTransferCalls(address cancelContract, address createContract, uint256 streamId) internal {
        expectCallToCancel(cancelContract, streamId);

        // Asset flow: Sablier → proxy → proxy owner
        // Expect transfers from Sablier to the proxy, and then from the proxy to the proxy owner.
        expectCallToTransfer({ to: address(proxy), amount: defaults.PER_STREAM_AMOUNT() });
        expectCallToTransfer({ to: users.sender.addr, amount: defaults.PER_STREAM_AMOUNT() });

        // Asset flow: proxy owner → proxy → Sablier
        // Expect transfers from the proxy owner to the proxy, and then from the proxy to the Sablier contract.
        expectCallToTransferFrom({ from: users.sender.addr, to: address(proxy), amount: defaults.PER_STREAM_AMOUNT() });
        expectCallToTransferFrom({ from: address(proxy), to: createContract, amount: defaults.PER_STREAM_AMOUNT() });
    }
}
