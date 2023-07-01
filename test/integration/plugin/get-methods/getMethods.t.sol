// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { SablierV2ProxyPlugin } from "src/SablierV2ProxyPlugin.sol";

import { Integration_Test } from "../../Integration.t.sol";

contract GetMethods_Integration_Test is Integration_Test {
    function test_GetMethods() external {
        bytes4[] memory actualMethods = plugin.getMethods();
        bytes4[] memory expectedMethods = new bytes4[](1);
        expectedMethods[0] = SablierV2ProxyPlugin.onStreamCanceled.selector;
        assertEq(actualMethods, expectedMethods, "methods do not match");
    }
}
