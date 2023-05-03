// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { SablierV2ProxyPlugin } from "src/SablierV2ProxyPlugin.sol";

import { Unit_Test } from "../../Unit.t.sol";

contract MethodList_Unit_Test is Unit_Test {
    function test_MethodList() external {
        bytes4[] memory actualMethodList = plugin.methodList();
        bytes4[] memory expectedMethodList = new bytes4[](1);
        expectedMethodList[0] = SablierV2ProxyPlugin.onStreamCanceled.selector;
        assertEq(actualMethodList, expectedMethodList, "method list does not match");
    }
}
