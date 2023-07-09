// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { LockupDynamic, LockupLinear } from "@sablier/v2-core/types/DataTypes.sol";

import { IWrappedNativeAsset } from "src/interfaces/IWrappedNativeAsset.sol";
import { Errors } from "src/libraries/Errors.sol";

import { Integration_Test } from "../../Integration.t.sol";

/// @dev This contracts tests the following functions:
/// - `wrapAndCreateWithDeltas`
/// - `wrapAndCreateWithDurations`
/// - `wrapAndCreateWithMilestones`
/// - `wrapAndCreateWithRange`
contract WrapAndCreate_Integration_Test is Integration_Test {
    modifier whenDelegateCalled() {
        _;
    }

    modifier whenCreditAmountEqualToMsgValue() {
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                 CREATE WITH DELTAS
    //////////////////////////////////////////////////////////////////////////*/

    function test_RevertWhen_WrapAndCreateWithDeltas_NotDelegateCalled() external {
        LockupDynamic.CreateWithDeltas memory createParams = defaults.createWithDeltas(weth);
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        target.wrapAndCreateWithDeltas(lockupDynamic, createParams);
    }

    function test_RevertWhen_WrapAndCreateWithDeltas_CreditAmountNotEqualToMsgValue() external whenDelegateCalled {
        uint256 msgValue = defaults.ETHER_AMOUNT();
        LockupDynamic.CreateWithDeltas memory createParams = defaults.createWithDeltas(wlc);
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierV2ProxyTarget_CreditAmountMismatch.selector, msgValue, msgValue - 1 wei
            )
        );
        bytes memory data = abi.encodeCall(target.wrapAndCreateWithDeltas, (lockupDynamic, createParams));
        aliceProxy.execute{ value: msgValue }(address(target), data);
    }

    function test_WrapAndCreateWithDeltas() external whenDelegateCalled whenCreditAmountEqualToMsgValue {
        // Expect the correct calls to be made.
        vm.expectCall(address(weth), abi.encodeCall(IWrappedNativeAsset.deposit, ()));
        expectCallToTransferFrom({
            asset_: address(weth),
            from: address(aliceProxy),
            to: address(lockupDynamic),
            amount: defaults.ETHER_AMOUNT()
        });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data =
            abi.encodeCall(target.wrapAndCreateWithDeltas, (lockupDynamic, defaults.createWithDeltas(weth)));
        bytes memory response = aliceProxy.execute{ value: defaults.ETHER_AMOUNT() }(address(target), data);

        // Assert that the stream has been created successfully.
        uint256 actualStreamId = abi.decode(response, (uint256));
        uint256 expectedStreamId = lockupDynamic.nextStreamId() - 1;
        assertEq(actualStreamId, expectedStreamId, "stream id mismatch");
    }

    /*//////////////////////////////////////////////////////////////////////////
                               CREATE WITH DURATIONS
    //////////////////////////////////////////////////////////////////////////*/

    function test_RevertWhen_WrapAndCreateWithDurations_NotDelegateCalled() external {
        LockupLinear.CreateWithDurations memory createParams = defaults.createWithDurations(weth);
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        target.wrapAndCreateWithDurations(lockupLinear, createParams);
    }

    function test_RevertWhen_WrapAndCreateWithDurations_CreditAmountNotEqualToMsgValue() external whenDelegateCalled {
        uint256 msgValue = defaults.ETHER_AMOUNT();
        LockupLinear.CreateWithDurations memory createParams = defaults.createWithDurations(wlc);
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierV2ProxyTarget_CreditAmountMismatch.selector, msgValue, msgValue - 1 wei
            )
        );
        bytes memory data = abi.encodeCall(target.wrapAndCreateWithDurations, (lockupLinear, createParams));
        aliceProxy.execute{ value: msgValue }(address(target), data);
    }

    function test_WrapAndCreateWithDurations() external whenDelegateCalled whenCreditAmountEqualToMsgValue {
        // Expect the correct calls to be made.
        vm.expectCall(address(weth), abi.encodeCall(IWrappedNativeAsset.deposit, ()));
        expectCallToTransferFrom({
            asset_: address(weth),
            from: address(aliceProxy),
            to: address(lockupLinear),
            amount: defaults.ETHER_AMOUNT()
        });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data =
            abi.encodeCall(target.wrapAndCreateWithDurations, (lockupLinear, defaults.createWithDurations(weth)));
        bytes memory response = aliceProxy.execute{ value: defaults.ETHER_AMOUNT() }(address(target), data);

        // Assert that the stream has been created successfully.
        uint256 actualStreamId = abi.decode(response, (uint256));
        uint256 expectedStreamId = lockupLinear.nextStreamId() - 1;
        assertEq(actualStreamId, expectedStreamId, "stream id mismatch");
    }

    /*//////////////////////////////////////////////////////////////////////////
                               CREATE WITH MILESTONES
    //////////////////////////////////////////////////////////////////////////*/

    function test_RevertWhen_WrapAndCreateWithMilestones_NotDelegateCalled() external {
        LockupDynamic.CreateWithMilestones memory createParams = defaults.createWithMilestones(weth);
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        target.wrapAndCreateWithMilestones(lockupDynamic, createParams);
    }

    function test_RevertWhen_WrapAndCreateWithMilestones_CreditAmountNotEqualToMsgValue() external whenDelegateCalled {
        uint256 msgValue = defaults.ETHER_AMOUNT();
        LockupDynamic.CreateWithMilestones memory createParams = defaults.createWithMilestones(wlc);
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierV2ProxyTarget_CreditAmountMismatch.selector, msgValue, msgValue - 1 wei
            )
        );
        bytes memory data = abi.encodeCall(target.wrapAndCreateWithMilestones, (lockupDynamic, createParams));
        aliceProxy.execute{ value: msgValue }(address(target), data);
    }

    function test_WrapAndCreateWithMilestones() external whenDelegateCalled whenCreditAmountEqualToMsgValue {
        // Expect the correct calls to be made.
        vm.expectCall(address(weth), abi.encodeCall(IWrappedNativeAsset.deposit, ()));
        expectCallToTransferFrom({
            asset_: address(weth),
            from: address(aliceProxy),
            to: address(lockupDynamic),
            amount: defaults.ETHER_AMOUNT()
        });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data =
            abi.encodeCall(target.wrapAndCreateWithMilestones, (lockupDynamic, defaults.createWithMilestones(weth)));
        bytes memory response = aliceProxy.execute{ value: defaults.ETHER_AMOUNT() }(address(target), data);

        // Assert that the stream has been created successfully.
        uint256 actualStreamId = abi.decode(response, (uint256));
        uint256 expectedStreamId = lockupDynamic.nextStreamId() - 1;
        assertEq(actualStreamId, expectedStreamId, "stream id mismatch");
    }
    /*//////////////////////////////////////////////////////////////////////////
                                 CREATE WITH RANGE
    //////////////////////////////////////////////////////////////////////////*/

    function test_RevertWhen_WrapAndCreateWithRange_NotDelegateCalled() external {
        LockupLinear.CreateWithDurations memory createParams = defaults.createWithDurations(weth);
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        target.wrapAndCreateWithDurations(lockupLinear, createParams);
    }

    function test_RevertWhen_WrapAndCreateWithRange_CreditAmountNotEqualToMsgValue() external whenDelegateCalled {
        uint256 msgValue = defaults.ETHER_AMOUNT();
        LockupLinear.CreateWithRange memory createParams = defaults.createWithRange(wlc);
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierV2ProxyTarget_CreditAmountMismatch.selector, msgValue, msgValue - 1 wei
            )
        );
        bytes memory data = abi.encodeCall(target.wrapAndCreateWithRange, (lockupLinear, createParams));
        aliceProxy.execute{ value: msgValue }(address(target), data);
    }

    function test_WrapAndCreateWithRange() external whenDelegateCalled whenCreditAmountEqualToMsgValue {
        // Expect the correct calls to be made.
        vm.expectCall(address(weth), abi.encodeCall(IWrappedNativeAsset.deposit, ()));
        expectCallToTransferFrom({
            asset_: address(weth),
            from: address(aliceProxy),
            to: address(lockupLinear),
            amount: defaults.ETHER_AMOUNT()
        });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data =
            abi.encodeCall(target.wrapAndCreateWithRange, (lockupLinear, defaults.createWithRange(weth)));
        bytes memory response = aliceProxy.execute{ value: defaults.ETHER_AMOUNT() }(address(target), data);

        // Assert that the stream has been created successfully.
        uint256 actualStreamId = abi.decode(response, (uint256));
        uint256 expectedStreamId = lockupLinear.nextStreamId() - 1;
        assertEq(actualStreamId, expectedStreamId, "stream id mismatch");
    }
}
