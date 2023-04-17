// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IWrappedNativeAsset } from "src/interfaces/external/IWrappedNativeAsset.sol";

import { Unit_Test } from "../Unit.t.sol";
import { DefaultParams } from "../../helpers/DefaultParams.t.sol";

contract WrapEtherAndCreate_Test is Unit_Test {
    function setUp() public virtual override {
        Unit_Test.setUp();

        changePrank({ msgSender: users.sender.addr });
    }

    function test_WrapEtherAndCreateWithDeltas() external {
        vm.expectCall(address(weth), abi.encodeCall(IWrappedNativeAsset.deposit, ()));
        expectTransferFromCall(address(weth), address(proxy), address(dynamic), DefaultParams.ETHER_AMOUNT);
        bytes memory data = abi.encodeCall(
            target.wrapAndCreateWithDeltas, (dynamic, DefaultParams.createWithDeltas(users, address(proxy), weth))
        );
        bytes memory response = proxy.execute{ value: DefaultParams.ETHER_AMOUNT }(address(target), data);
        uint256 actualStreamId = abi.decode(response, (uint256));
        uint256 expectedStreamId = 1;
        assertEq(actualStreamId, expectedStreamId);
    }

    function test_WrapEtherAndCreateWithDurations() external {
        vm.expectCall(address(weth), abi.encodeCall(IWrappedNativeAsset.deposit, ()));
        expectTransferFromCall(address(weth), address(proxy), address(linear), DefaultParams.ETHER_AMOUNT);
        bytes memory data = abi.encodeCall(
            target.wrapAndCreateWithDurations, (linear, DefaultParams.createWithDurations(users, address(proxy), weth))
        );
        bytes memory response = proxy.execute{ value: DefaultParams.ETHER_AMOUNT }(address(target), data);
        uint256 actualStreamId = abi.decode(response, (uint256));
        uint256 expectedStreamId = 1;
        assertEq(actualStreamId, expectedStreamId);
    }

    function test_WrapEtherAndCreateWithMilestones() external {
        vm.expectCall(address(weth), abi.encodeCall(IWrappedNativeAsset.deposit, ()));
        expectTransferFromCall(address(weth), address(proxy), address(dynamic), DefaultParams.ETHER_AMOUNT);
        bytes memory data = abi.encodeCall(
            target.wrapAndCreateWithMilestones,
            (dynamic, DefaultParams.createWithMilestones(users, address(proxy), weth))
        );
        bytes memory response = proxy.execute{ value: DefaultParams.ETHER_AMOUNT }(address(target), data);
        uint256 actualStreamId = abi.decode(response, (uint256));
        uint256 expectedStreamId = 1;
        assertEq(actualStreamId, expectedStreamId);
    }

    function test_WrapEtherAndCreateWithRange() external {
        vm.expectCall(address(weth), abi.encodeCall(IWrappedNativeAsset.deposit, ()));
        expectTransferFromCall(address(weth), address(proxy), address(linear), DefaultParams.ETHER_AMOUNT);
        bytes memory data = abi.encodeCall(
            target.wrapAndCreateWithRange, (linear, DefaultParams.createWithRange(users, address(proxy), weth))
        );
        bytes memory response = proxy.execute{ value: DefaultParams.ETHER_AMOUNT }(address(target), data);
        uint256 actualStreamId = abi.decode(response, (uint256));
        uint256 expectedStreamId = 1;
        assertEq(actualStreamId, expectedStreamId);
    }
}
