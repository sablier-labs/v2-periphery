// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IWETH9 } from "src/interfaces/external/IWETH9.sol";

import { Unit_Test } from "../Unit.t.sol";
import { DefaultParams } from "../../helpers/DefaultParams.t.sol";

contract WrapEtherAndCreateWithDurations_Test is Unit_Test {
    function setUp() public virtual override {
        Unit_Test.setUp();

        changePrank(users.sender);
    }

    function test_WrapEtherAndCreateWithDurations() external {
        vm.expectCall(address(weth9), abi.encodeCall(IWETH9.deposit, ()));
        expectTransferFromCall(address(weth9), address(proxy), address(linear), DefaultParams.ETHER_AMOUNT);
        bytes memory data = abi.encodeCall(
            target.wrapEtherAndCreateWithDurations,
            (linear, weth9, DefaultParams.createWithDurations(users, address(proxy), weth9))
        );
        bytes memory response = proxy.execute{ value: DefaultParams.ETHER_AMOUNT }(address(target), data);
        uint256 actualStreamId = abi.decode(response, (uint256));
        uint256 expectedStreamId = 1;
        assertEq(actualStreamId, expectedStreamId);
    }
}
