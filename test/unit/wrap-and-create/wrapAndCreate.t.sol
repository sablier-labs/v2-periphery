// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IWrappedNativeAsset } from "src/interfaces/external/IWrappedNativeAsset.sol";

import { Base_Test } from "../../Base.t.sol";
import { Defaults } from "../../helpers/Defaults.t.sol";

/// @dev This contracts tests the following functions:
/// - `wrapEtherAndCreateWithDeltas`
/// - `wrapEtherAndCreateWithDurations`
/// - `wrapEtherAndCreateWithMilestones`
/// - `wrapEtherAndCreateWithRange`
contract WrapAndCreate_Unit_Test is Base_Test {
    function test_WrapAndCreateWithDeltas() external {
        // Expect the correct calls to be made.
        vm.expectCall(address(weth), abi.encodeCall(IWrappedNativeAsset.deposit, ()));
        expectCallToTransferFrom({
            asset: address(weth),
            from: address(proxy),
            to: address(dynamic),
            amount: Defaults.ETHER_AMOUNT
        });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data =
            abi.encodeCall(target.wrapAndCreateWithDeltas, (dynamic, Defaults.createWithDeltas(users, proxy, weth)));
        bytes memory response = proxy.execute{ value: Defaults.ETHER_AMOUNT }(address(target), data);

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
            amount: Defaults.ETHER_AMOUNT
        });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data = abi.encodeCall(
            target.wrapAndCreateWithDurations, (linear, Defaults.createWithDurations(users, proxy, weth))
        );
        bytes memory response = proxy.execute{ value: Defaults.ETHER_AMOUNT }(address(target), data);

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
            amount: Defaults.ETHER_AMOUNT
        });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data = abi.encodeCall(
            target.wrapAndCreateWithMilestones, (dynamic, Defaults.createWithMilestones(users, proxy, weth))
        );
        bytes memory response = proxy.execute{ value: Defaults.ETHER_AMOUNT }(address(target), data);

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
            amount: Defaults.ETHER_AMOUNT
        });

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data =
            abi.encodeCall(target.wrapAndCreateWithRange, (linear, Defaults.createWithRange(users, proxy, weth)));
        bytes memory response = proxy.execute{ value: Defaults.ETHER_AMOUNT }(address(target), data);

        // Assert that the stream has been created successfully.
        uint256 actualStreamId = abi.decode(response, (uint256));
        uint256 expectedStreamId = linear.nextStreamId() - 1;
        assertEq(actualStreamId, expectedStreamId, "stream id mismatch");
    }
}
