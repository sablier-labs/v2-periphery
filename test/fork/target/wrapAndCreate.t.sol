// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { IWrappedNativeAsset } from "src/interfaces/IWrappedNativeAsset.sol";
import { LockupDynamic, LockupLinear } from "src/types/DataTypes.sol";

import { Fork_Test } from "../Fork.t.sol";

/// @dev Runs against $WETH only.
contract WrapAndCreate_Fork_Test is Fork_Test {
    constructor() Fork_Test(IERC20(WETH_ADDRESS)) { }

    function testForkFuzz_WrapAndCreateWithMilestones(uint256 amount0, uint256 amount1) external {
        uint256 max = users.alice.addr.balance - 1 ether;
        amount0 = _bound(amount0, 1 wei, max / 2);
        amount1 = _bound(amount1, 1 wei, max / 2);
        uint256 totalAmount = amount0 + amount1;

        // Expect the correct calls to be made.
        vm.expectCall(address(weth), abi.encodeCall(IWrappedNativeAsset.deposit, ()));
        expectCallToTransferFrom({
            asset_: address(weth),
            from: address(proxy),
            to: address(dynamic),
            amount: totalAmount
        });

        LockupDynamic.CreateWithMilestones memory createParams = defaults.createWithMilestones(weth);
        createParams.segments[0].amount = uint128(amount0);
        createParams.segments[1].amount = uint128(amount1);

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data = abi.encodeCall(target.wrapAndCreateWithMilestones, (dynamic, createParams));
        bytes memory response = proxy.execute{ value: totalAmount }(address(target), data);

        // Assert that the stream has been created successfully.
        uint256 actualStreamId = abi.decode(response, (uint256));
        uint256 expectedStreamId = dynamic.nextStreamId() - 1;
        assertEq(actualStreamId, expectedStreamId, "stream id mismatch");
    }

    function testForkFuzz_WrapAndCreateWithRange(uint256 etherAmount) external {
        etherAmount = _bound(etherAmount, 1 wei, users.alice.addr.balance - 1 ether);

        // Expect the correct calls to be made.
        vm.expectCall(address(weth), abi.encodeCall(IWrappedNativeAsset.deposit, ()));
        expectCallToTransferFrom({
            asset_: address(weth),
            from: address(proxy),
            to: address(linear),
            amount: etherAmount
        });

        // ABI encode the parameters and call the function via the proxy.
        LockupLinear.CreateWithRange memory createParams = defaults.createWithRange(weth);
        bytes memory data = abi.encodeCall(target.wrapAndCreateWithRange, (linear, createParams));
        bytes memory response = proxy.execute{ value: etherAmount }(address(target), data);

        // Assert that the stream has been created successfully.
        uint256 actualStreamId = abi.decode(response, (uint256));
        uint256 expectedStreamId = linear.nextStreamId() - 1;
        assertEq(actualStreamId, expectedStreamId, "stream id mismatch");
    }
}
