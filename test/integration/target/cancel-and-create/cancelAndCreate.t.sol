// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ISablierV2Lockup } from "@sablier/v2-core/interfaces/ISablierV2Lockup.sol";
import { ISablierV2LockupDynamic } from "@sablier/v2-core/interfaces/ISablierV2LockupDynamic.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";
import { LockupLinear, LockupDynamic } from "@sablier/v2-core/types/DataTypes.sol";

import { Errors } from "src/libraries/Errors.sol";
import { Permit2Params } from "src/types/Permit2.sol";

import { Integration_Test } from "../../Integration.t.sol";

/// @dev This contracts tests the following functions:
/// - `cancelAndCreateWithDeltas`
/// - `cancelAndCreateWithDurations`
/// - `cancelAndCreateWithMilestones`
/// - `cancelAndCreateWithRange`
contract CancelAndCreate_Integration_Test is Integration_Test {
    modifier whenDelegateCalled() {
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                 CREATE WITH DELTAS
    //////////////////////////////////////////////////////////////////////////*/

    function test_RevertWhen_CancelAndCreateWithDeltas_NotDelegateCalled() external {
        LockupDynamic.CreateWithDeltas memory createParams;
        Permit2Params memory permit2Params;
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        target.cancelAndCreateWithDeltas(lockupDynamic, 0, lockupDynamic, createParams, permit2Params);
    }

    function test_CancelAndCreateWithDeltas_SameSablierContract() external whenDelegateCalled {
        // Create the stream due to be canceled.
        uint256 streamId = createWithDeltas();

        // Expect the correct calls to be made.
        ISablierV2Lockup cancelContract = lockupDynamic;
        ISablierV2LockupDynamic createContract = lockupDynamic;
        expectCallsToCancelAndTransfer(cancelContract, createContract, streamId);
        expectCallToCreateWithDeltas({ params: defaults.createWithDeltas() });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithDeltas,
            (
                cancelContract,
                streamId,
                createContract,
                defaults.createWithDeltas(),
                defaults.permit2Params(defaults.PER_STREAM_AMOUNT())
            )
        );
        bytes memory response = aliceProxy.execute(address(target), data);

        // Assert that the new stream has been created successfully.
        uint256 actualNewStreamId = abi.decode(response, (uint256));
        uint256 expectedNewStreamId = createContract.nextStreamId() - 1;
        assertEq(actualNewStreamId, expectedNewStreamId, "new stream id mismatch");
    }

    function test_CancelAndCreateWithDeltas_AcrossSablierContracts() external whenDelegateCalled {
        // Create the stream due to be canceled.
        uint256 streamId = createWithRange();

        // Expect the correct calls to be made.
        ISablierV2Lockup cancelContract = lockupLinear;
        ISablierV2LockupDynamic createContract = lockupDynamic;
        expectCallsToCancelAndTransfer(cancelContract, createContract, streamId);
        expectCallToCreateWithDeltas({ params: defaults.createWithDeltas() });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithDeltas,
            (
                cancelContract,
                streamId,
                createContract,
                defaults.createWithDeltas(),
                defaults.permit2Params(defaults.PER_STREAM_AMOUNT())
            )
        );
        bytes memory response = aliceProxy.execute(address(target), data);

        // Assert that the new stream has been created successfully.
        uint256 actualNewStreamId = abi.decode(response, (uint256));
        uint256 expectedNewStreamId = createContract.nextStreamId() - 1;
        assertEq(actualNewStreamId, expectedNewStreamId, "new stream id mismatch");
    }

    /*//////////////////////////////////////////////////////////////////////////
                               CREATE WITH DURATIONS
    //////////////////////////////////////////////////////////////////////////*/

    function test_RevertWhen_CancelAndCreateWithDurations_NotDelegateCalled() external {
        LockupLinear.CreateWithDurations memory createParams;
        Permit2Params memory permit2Params;
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        target.cancelAndCreateWithDurations(lockupLinear, 0, lockupLinear, createParams, permit2Params);
    }

    function test_CancelAndCreateWithDurations_SameSablierContract() external whenDelegateCalled {
        // Create the stream due to be canceled.
        uint256 streamId = createWithDurations();

        // Expect the correct calls to be made.
        ISablierV2Lockup cancelContract = lockupLinear;
        ISablierV2LockupLinear createContract = lockupLinear;
        expectCallsToCancelAndTransfer(cancelContract, createContract, streamId);
        expectCallToCreateWithDurations({ params: defaults.createWithDurations() });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithDurations,
            (
                cancelContract,
                streamId,
                createContract,
                defaults.createWithDurations(),
                defaults.permit2Params(defaults.PER_STREAM_AMOUNT())
            )
        );
        bytes memory response = aliceProxy.execute(address(target), data);

        // Assert that the new stream has been created successfully.
        uint256 actualNewStreamId = abi.decode(response, (uint256));
        uint256 expectedNewStreamId = createContract.nextStreamId() - 1;
        assertEq(actualNewStreamId, expectedNewStreamId, "new stream id mismatch");
    }

    function test_CancelAndCreateWithDurations_AcrossSablierContracts() external whenDelegateCalled {
        // Create the stream due to be canceled.
        uint256 streamId = createWithMilestones();

        // Expect the correct calls to be made.
        ISablierV2Lockup cancelContract = lockupDynamic;
        ISablierV2LockupLinear createContract = lockupLinear;
        expectCallsToCancelAndTransfer(cancelContract, createContract, streamId);
        expectCallToCreateWithDurations({ params: defaults.createWithDurations() });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithDurations,
            (
                cancelContract,
                streamId,
                createContract,
                defaults.createWithDurations(),
                defaults.permit2Params(defaults.PER_STREAM_AMOUNT())
            )
        );
        bytes memory response = aliceProxy.execute(address(target), data);

        // Assert that the new stream has been created successfully.
        uint256 actualNewStreamId = abi.decode(response, (uint256));
        uint256 expectedNewStreamId = createContract.nextStreamId() - 1;
        assertEq(actualNewStreamId, expectedNewStreamId, "new stream id mismatch");
    }

    /*//////////////////////////////////////////////////////////////////////////
                               CREATE WITH MILESTONES
    //////////////////////////////////////////////////////////////////////////*/

    function test_RevertWhen_CancelAndCreateWithMilestones_NotDelegateCalled() external {
        LockupDynamic.CreateWithMilestones memory createParams;
        Permit2Params memory permit2Params;
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        target.cancelAndCreateWithMilestones(lockupDynamic, 0, lockupDynamic, createParams, permit2Params);
    }

    function test_CancelAndCreateWithMilestones_SameSablierContract() external whenDelegateCalled {
        // Create the stream due to be canceled.
        uint256 streamId = createWithMilestones();

        // Expect the correct calls to be made.
        ISablierV2Lockup cancelContract = lockupDynamic;
        ISablierV2LockupDynamic createContract = lockupDynamic;
        expectCallsToCancelAndTransfer(cancelContract, createContract, streamId);
        expectCallToCreateWithMilestones({ params: defaults.createWithMilestones() });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithMilestones,
            (
                cancelContract,
                streamId,
                createContract,
                defaults.createWithMilestones(),
                defaults.permit2Params(defaults.PER_STREAM_AMOUNT())
            )
        );
        bytes memory response = aliceProxy.execute(address(target), data);

        // Assert that the new stream has been created successfully.
        uint256 actualNewStreamId = abi.decode(response, (uint256));
        uint256 expectedNewStreamId = createContract.nextStreamId() - 1;
        assertEq(actualNewStreamId, expectedNewStreamId, "new stream id mismatch");
    }

    function test_CancelAndCreateWithMilestones_AcrossSablierContracts() external whenDelegateCalled {
        // Create the stream due to be canceled.
        uint256 streamId = createWithRange();

        // Expect the correct calls to be made.
        ISablierV2Lockup cancelContract = lockupLinear;
        ISablierV2LockupDynamic createContract = lockupDynamic;
        expectCallsToCancelAndTransfer(cancelContract, createContract, streamId);
        expectCallToCreateWithMilestones({ params: defaults.createWithMilestones() });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithMilestones,
            (
                cancelContract,
                streamId,
                createContract,
                defaults.createWithMilestones(),
                defaults.permit2Params(defaults.PER_STREAM_AMOUNT())
            )
        );
        bytes memory response = aliceProxy.execute(address(target), data);

        // Assert that the new stream has been created successfully.
        uint256 actualNewStreamId = abi.decode(response, (uint256));
        uint256 expectedNewStreamId = createContract.nextStreamId() - 1;
        assertEq(actualNewStreamId, expectedNewStreamId, "new stream id mismatch");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                 CREATE WITH RANGE
    //////////////////////////////////////////////////////////////////////////*/

    function test_RevertWhen_CancelAndCreateWithRange_NotDelegateCalled() external {
        LockupLinear.CreateWithRange memory createParams;
        Permit2Params memory permit2Params;
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        target.cancelAndCreateWithRange(lockupLinear, 0, lockupLinear, createParams, permit2Params);
    }

    function test_CancelAndCreateWithRange_SameSablierContract() external whenDelegateCalled {
        // Create the stream due to be canceled.
        uint256 streamId = createWithRange();

        // Expect the correct calls to be made.
        ISablierV2Lockup cancelContract = lockupLinear;
        ISablierV2LockupLinear createContract = lockupLinear;
        expectCallsToCancelAndTransfer(cancelContract, createContract, streamId);
        expectCallToCreateWithRange({ params: defaults.createWithRange() });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithRange,
            (
                cancelContract,
                streamId,
                createContract,
                defaults.createWithRange(),
                defaults.permit2Params(defaults.PER_STREAM_AMOUNT())
            )
        );
        bytes memory response = aliceProxy.execute(address(target), data);

        // Assert that the new stream has been created successfully.
        uint256 actualNewStreamId = abi.decode(response, (uint256));
        uint256 expectedNewStreamId = createContract.nextStreamId() - 1;
        assertEq(actualNewStreamId, expectedNewStreamId, "new stream id mismatch");
    }

    function test_CancelAndCreateWithRange_AcrossSablierContracts() external whenDelegateCalled {
        // Create the stream due to be canceled.
        uint256 streamId = createWithMilestones();

        // Expect the correct calls to be made.
        ISablierV2Lockup cancelContract = lockupDynamic;
        ISablierV2LockupLinear createContract = lockupLinear;
        expectCallsToCancelAndTransfer(cancelContract, createContract, streamId);
        expectCallToCreateWithRange({ params: defaults.createWithRange() });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithRange,
            (
                cancelContract,
                streamId,
                createContract,
                defaults.createWithRange(),
                defaults.permit2Params(defaults.PER_STREAM_AMOUNT())
            )
        );
        bytes memory response = aliceProxy.execute(address(target), data);

        // Assert that the new stream has been created successfully.
        uint256 actualNewStreamId = abi.decode(response, (uint256));
        uint256 expectedNewStreamId = createContract.nextStreamId() - 1;
        assertEq(actualNewStreamId, expectedNewStreamId, "new stream id mismatch");
    }
}
