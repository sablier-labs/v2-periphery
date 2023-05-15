// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ISablierV2Lockup } from "@sablier/v2-core/interfaces/ISablierV2Lockup.sol";
import { ISablierV2LockupDynamic } from "@sablier/v2-core/interfaces/ISablierV2LockupDynamic.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";
import { LockupLinear, LockupDynamic } from "@sablier/v2-core/types/DataTypes.sol";

import { Errors } from "src/libraries/Errors.sol";
import { Permit2Params } from "src/types/DataTypes.sol";

import { Unit_Test } from "../../Unit.t.sol";

/// @dev This contracts tests the following functions:
/// - `cancelAndCreateWithDeltas`
/// - `cancelAndCreateWithDurations`
/// - `cancelAndCreateWithMilestones`
/// - `cancelAndCreateWithRange`
contract CancelAndCreate_Unit_Test is Unit_Test {
    modifier whenDelegateCall() {
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                 CREATE WITH DELTAS
    //////////////////////////////////////////////////////////////////////////*/

    function test_RevertWhen_CancelAndCreateWithDeltas_CallNotDelegateCall() external {
        LockupDynamic.CreateWithDeltas memory createParams;
        Permit2Params memory permit2Params;
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        target.cancelAndCreateWithDeltas(dynamic, dynamic, 0, createParams, permit2Params);
    }

    function test_CancelAndCreateWithDeltas_SameSablierContract() external whenDelegateCall {
        // Create the stream due to be canceled.
        uint256 streamId = createWithDeltas();

        // Expect the correct calls to be made.
        ISablierV2Lockup cancelContract = dynamic;
        ISablierV2LockupDynamic createContract = dynamic;
        expectCancelAndTransferCalls(cancelContract, createContract, streamId);
        expectCallToCreateWithDeltas({ params: defaults.createWithDeltas() });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithDeltas,
            (
                cancelContract,
                createContract,
                streamId,
                defaults.createWithDeltas(),
                defaults.permit2Params(defaults.PER_STREAM_AMOUNT())
            )
        );
        bytes memory response = proxy.execute(address(target), data);

        // Assert that the new stream has been created successfully.
        uint256 actualNewStreamId = abi.decode(response, (uint256));
        uint256 expectedNewStreamId = createContract.nextStreamId() - 1;
        assertEq(actualNewStreamId, expectedNewStreamId, "new stream id mismatch");
    }

    function test_CancelAndCreateWithDeltas_AcrossSablierContracts() external {
        // Create the stream due to be canceled.
        uint256 streamId = createWithRange();

        // Expect the correct calls to be made.
        ISablierV2Lockup cancelContract = linear;
        ISablierV2LockupDynamic createContract = dynamic;
        expectCancelAndTransferCalls(cancelContract, createContract, streamId);
        expectCallToCreateWithDeltas({ params: defaults.createWithDeltas() });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithDeltas,
            (
                cancelContract,
                createContract,
                streamId,
                defaults.createWithDeltas(),
                defaults.permit2Params(defaults.PER_STREAM_AMOUNT())
            )
        );
        bytes memory response = proxy.execute(address(target), data);

        // Assert that the new stream has been created successfully.
        uint256 actualNewStreamId = abi.decode(response, (uint256));
        uint256 expectedNewStreamId = createContract.nextStreamId() - 1;
        assertEq(actualNewStreamId, expectedNewStreamId, "new stream id mismatch");
    }

    /*//////////////////////////////////////////////////////////////////////////
                               CREATE WITH DURATIONS
    //////////////////////////////////////////////////////////////////////////*/

    function test_RevertWhen_CancelAndCreateWithDurations_CallNotDelegateCall() external {
        LockupLinear.CreateWithDurations memory createParams;
        Permit2Params memory permit2Params;
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        target.cancelAndCreateWithDurations(linear, linear, 0, createParams, permit2Params);
    }

    function test_CancelAndCreateWithDurations_SameSablierContract() external whenDelegateCall {
        // Create the stream due to be canceled.
        uint256 streamId = createWithDurations();

        // Expect the correct calls to be made.
        ISablierV2Lockup cancelContract = linear;
        ISablierV2LockupLinear createContract = linear;
        expectCancelAndTransferCalls(cancelContract, createContract, streamId);
        expectCallToCreateWithDurations({ params: defaults.createWithDurations() });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithDurations,
            (
                cancelContract,
                createContract,
                streamId,
                defaults.createWithDurations(),
                defaults.permit2Params(defaults.PER_STREAM_AMOUNT())
            )
        );
        bytes memory response = proxy.execute(address(target), data);

        // Assert that the new stream has been created successfully.
        uint256 actualNewStreamId = abi.decode(response, (uint256));
        uint256 expectedNewStreamId = createContract.nextStreamId() - 1;
        assertEq(actualNewStreamId, expectedNewStreamId, "new stream id mismatch");
    }

    function test_CancelAndCreateWithDurations_AcrossSablierContracts() external {
        // Create the stream due to be canceled.
        uint256 streamId = createWithMilestones();

        // Expect the correct calls to be made.
        ISablierV2Lockup cancelContract = dynamic;
        ISablierV2LockupLinear createContract = linear;
        expectCancelAndTransferCalls(cancelContract, createContract, streamId);
        expectCallToCreateWithDurations({ params: defaults.createWithDurations() });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithDurations,
            (
                cancelContract,
                createContract,
                streamId,
                defaults.createWithDurations(),
                defaults.permit2Params(defaults.PER_STREAM_AMOUNT())
            )
        );
        bytes memory response = proxy.execute(address(target), data);

        // Assert that the new stream has been created successfully.
        uint256 actualNewStreamId = abi.decode(response, (uint256));
        uint256 expectedNewStreamId = createContract.nextStreamId() - 1;
        assertEq(actualNewStreamId, expectedNewStreamId, "new stream id mismatch");
    }

    /*//////////////////////////////////////////////////////////////////////////
                               CREATE WITH MILESTONES
    //////////////////////////////////////////////////////////////////////////*/

    function test_RevertWhen_CancelAndCreateWithMilestones_CallNotDelegateCall() external {
        LockupDynamic.CreateWithMilestones memory createParams;
        Permit2Params memory permit2Params;
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        target.cancelAndCreateWithMilestones(dynamic, dynamic, 0, createParams, permit2Params);
    }

    function test_CancelAndCreateWithMilestones_SameSablierContract() external whenDelegateCall {
        // Create the stream due to be canceled.
        uint256 streamId = createWithMilestones();

        // Expect the correct calls to be made.
        ISablierV2Lockup cancelContract = dynamic;
        ISablierV2LockupDynamic createContract = dynamic;
        expectCancelAndTransferCalls(cancelContract, createContract, streamId);
        expectCallToCreateWithMilestones({ params: defaults.createWithMilestones() });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithMilestones,
            (
                cancelContract,
                createContract,
                streamId,
                defaults.createWithMilestones(),
                defaults.permit2Params(defaults.PER_STREAM_AMOUNT())
            )
        );
        bytes memory response = proxy.execute(address(target), data);

        // Assert that the new stream has been created successfully.
        uint256 actualNewStreamId = abi.decode(response, (uint256));
        uint256 expectedNewStreamId = createContract.nextStreamId() - 1;
        assertEq(actualNewStreamId, expectedNewStreamId, "new stream id mismatch");
    }

    function test_CancelAndCreateWithMilestones_AcrossSablierContracts() external {
        // Create the stream due to be canceled.
        uint256 streamId = createWithRange();

        // Expect the correct calls to be made.
        ISablierV2Lockup cancelContract = linear;
        ISablierV2LockupDynamic createContract = dynamic;
        expectCancelAndTransferCalls(cancelContract, createContract, streamId);
        expectCallToCreateWithMilestones({ params: defaults.createWithMilestones() });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithMilestones,
            (
                cancelContract,
                createContract,
                streamId,
                defaults.createWithMilestones(),
                defaults.permit2Params(defaults.PER_STREAM_AMOUNT())
            )
        );
        bytes memory response = proxy.execute(address(target), data);

        // Assert that the new stream has been created successfully.
        uint256 actualNewStreamId = abi.decode(response, (uint256));
        uint256 expectedNewStreamId = createContract.nextStreamId() - 1;
        assertEq(actualNewStreamId, expectedNewStreamId, "new stream id mismatch");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                 CREATE WITH RANGE
    //////////////////////////////////////////////////////////////////////////*/

    function test_RevertWhen_CancelAndCreateWithRange_CallNotDelegateCall() external {
        LockupLinear.CreateWithRange memory createParams;
        Permit2Params memory permit2Params;
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        target.cancelAndCreateWithRange(linear, linear, 0, createParams, permit2Params);
    }

    function test_CancelAndCreateWithRange_SameSablierContract() external whenDelegateCall {
        // Create the stream due to be canceled.
        uint256 streamId = createWithRange();

        // Expect the correct calls to be made.
        ISablierV2Lockup cancelContract = linear;
        ISablierV2LockupLinear createContract = linear;
        expectCancelAndTransferCalls(cancelContract, createContract, streamId);
        expectCallToCreateWithRange({ params: defaults.createWithRange() });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithRange,
            (
                cancelContract,
                createContract,
                streamId,
                defaults.createWithRange(),
                defaults.permit2Params(defaults.PER_STREAM_AMOUNT())
            )
        );
        bytes memory response = proxy.execute(address(target), data);

        // Assert that the new stream has been created successfully.
        uint256 actualNewStreamId = abi.decode(response, (uint256));
        uint256 expectedNewStreamId = createContract.nextStreamId() - 1;
        assertEq(actualNewStreamId, expectedNewStreamId, "new stream id mismatch");
    }

    function test_CancelAndCreateWithRange_AcrossSablierContracts() external {
        // Create the stream due to be canceled.
        uint256 streamId = createWithMilestones();

        // Expect the correct calls to be made.
        ISablierV2Lockup cancelContract = dynamic;
        ISablierV2LockupLinear createContract = linear;
        expectCancelAndTransferCalls(cancelContract, createContract, streamId);
        expectCallToCreateWithRange({ params: defaults.createWithRange() });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithRange,
            (
                cancelContract,
                createContract,
                streamId,
                defaults.createWithRange(),
                defaults.permit2Params(defaults.PER_STREAM_AMOUNT())
            )
        );
        bytes memory response = proxy.execute(address(target), data);

        // Assert that the new stream has been created successfully.
        uint256 actualNewStreamId = abi.decode(response, (uint256));
        uint256 expectedNewStreamId = createContract.nextStreamId() - 1;
        assertEq(actualNewStreamId, expectedNewStreamId, "new stream id mismatch");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

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
