// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { LockupDynamic, LockupLinear } from "@sablier/v2-core/types/DataTypes.sol";

import { IWrappedNativeAsset } from "src/interfaces/IWrappedNativeAsset.sol";
import { Errors } from "src/libraries/Errors.sol";

import { Unit_Test } from "../../Unit.t.sol";

/// @dev This contracts tests the following functions:
/// - `wrapEtherAndCreateWithDeltas`
/// - `wrapEtherAndCreateWithDurations`
/// - `wrapEtherAndCreateWithMilestones`
/// - `wrapEtherAndCreateWithRange`
contract WrapAndCreate_Unit_Test is Unit_Test {
    modifier whenDelegateCall() {
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                 CREATE WITH DELTAS
    //////////////////////////////////////////////////////////////////////////*/

    function test_RevertWhen_WrapAndCreateWithDeltas_CallNotDelegateCall() external {
        LockupDynamic.CreateWithDeltas memory createParams = defaults.createWithDeltas(weth);
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        target.wrapAndCreateWithDeltas(dynamic, createParams);
    }

    function test_WrapAndCreateWithDeltas() external whenDelegateCall {
        // Expect the correct calls to be made.
        vm.expectCall(address(weth), abi.encodeCall(IWrappedNativeAsset.deposit, ()));
        expectCallToTransferFrom({
            asset: address(weth),
            from: address(proxy),
            to: address(dynamic),
            amount: defaults.ETHER_AMOUNT()
        });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data = abi.encodeCall(target.wrapAndCreateWithDeltas, (dynamic, defaults.createWithDeltas(weth)));
        bytes memory response = proxy.execute{ value: defaults.ETHER_AMOUNT() }(address(target), data);

        // Assert that the stream has been created successfully.
        uint256 actualStreamId = abi.decode(response, (uint256));
        uint256 expectedStreamId = dynamic.nextStreamId() - 1;
        assertEq(actualStreamId, expectedStreamId, "stream id mismatch");
    }

    /*//////////////////////////////////////////////////////////////////////////
                               CREATE WITH DURATIONS
    //////////////////////////////////////////////////////////////////////////*/

    function test_RevertWhen_WrapAndCreateWithDurations_CallNotDelegateCall() external {
        LockupLinear.CreateWithDurations memory createParams = defaults.createWithDurations(weth);
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        target.wrapAndCreateWithDurations(linear, createParams);
    }

    function test_WrapAndCreateWithDurations() external whenDelegateCall {
        // Expect the correct calls to be made.
        vm.expectCall(address(weth), abi.encodeCall(IWrappedNativeAsset.deposit, ()));
        expectCallToTransferFrom({
            asset: address(weth),
            from: address(proxy),
            to: address(linear),
            amount: defaults.ETHER_AMOUNT()
        });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data =
            abi.encodeCall(target.wrapAndCreateWithDurations, (linear, defaults.createWithDurations(weth)));
        bytes memory response = proxy.execute{ value: defaults.ETHER_AMOUNT() }(address(target), data);

        // Assert that the stream has been created successfully.
        uint256 actualStreamId = abi.decode(response, (uint256));
        uint256 expectedStreamId = linear.nextStreamId() - 1;
        assertEq(actualStreamId, expectedStreamId, "stream id mismatch");
    }

    /*//////////////////////////////////////////////////////////////////////////
                               CREATE WITH MILESTONES
    //////////////////////////////////////////////////////////////////////////*/

    function test_RevertWhen_WrapAndCreateWithMilestones_CallNotDelegateCall() external {
        LockupDynamic.CreateWithMilestones memory createParams = defaults.createWithMilestones(weth);
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        target.wrapAndCreateWithMilestones(dynamic, createParams);
    }

    function test_WrapAndCreateWithMilestones() external whenDelegateCall {
        // Expect the correct calls to be made.
        vm.expectCall(address(weth), abi.encodeCall(IWrappedNativeAsset.deposit, ()));
        expectCallToTransferFrom({
            asset: address(weth),
            from: address(proxy),
            to: address(dynamic),
            amount: defaults.ETHER_AMOUNT()
        });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data =
            abi.encodeCall(target.wrapAndCreateWithMilestones, (dynamic, defaults.createWithMilestones(weth)));
        bytes memory response = proxy.execute{ value: defaults.ETHER_AMOUNT() }(address(target), data);

        // Assert that the stream has been created successfully.
        uint256 actualStreamId = abi.decode(response, (uint256));
        uint256 expectedStreamId = dynamic.nextStreamId() - 1;
        assertEq(actualStreamId, expectedStreamId, "stream id mismatch");
    }
    /*//////////////////////////////////////////////////////////////////////////
                                 CREATE WITH RANGE
    //////////////////////////////////////////////////////////////////////////*/

    function test_RevertWhen_WrapAndCreateWithRange_CallNotDelegateCall() external {
        LockupLinear.CreateWithDurations memory createParams = defaults.createWithDurations(weth);
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        target.wrapAndCreateWithDurations(linear, createParams);
    }

    function test_WrapAndCreateWithRange() external whenDelegateCall {
        // Expect the correct calls to be made.
        vm.expectCall(address(weth), abi.encodeCall(IWrappedNativeAsset.deposit, ()));
        expectCallToTransferFrom({
            asset: address(weth),
            from: address(proxy),
            to: address(linear),
            amount: defaults.ETHER_AMOUNT()
        });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data = abi.encodeCall(target.wrapAndCreateWithRange, (linear, defaults.createWithRange(weth)));
        bytes memory response = proxy.execute{ value: defaults.ETHER_AMOUNT() }(address(target), data);

        // Assert that the stream has been created successfully.
        uint256 actualStreamId = abi.decode(response, (uint256));
        uint256 expectedStreamId = linear.nextStreamId() - 1;
        assertEq(actualStreamId, expectedStreamId, "stream id mismatch");
    }
}
