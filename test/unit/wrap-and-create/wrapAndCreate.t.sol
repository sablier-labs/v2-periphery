// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IWrappedNativeAsset } from "src/interfaces/IWrappedNativeAsset.sol";

import { Defaults } from "../../utils/Defaults.sol";
import { Unit_Test } from "../Unit.t.sol";

/// @dev This contracts tests the following functions:
/// - `wrapEtherAndCreateWithDeltas`
/// - `wrapEtherAndCreateWithDurations`
/// - `wrapEtherAndCreateWithMilestones`
/// - `wrapEtherAndCreateWithRange`
contract WrapAndCreate_Unit_Test is Unit_Test {
    function test_WrapAndCreateWithDeltas() external {
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

    function test_WrapAndCreateWithDurations() external {
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

    function test_WrapAndCreateWithMilestones() external {
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

    function test_WrapAndCreateWithRange() external {
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
