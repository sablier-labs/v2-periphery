// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ISablierV2LockupSender } from "@sablier/v2-core/interfaces/hooks/ISablierV2LockupSender.sol";

import { Base_Test } from "../../Base.t.sol";

contract MethodList_Unit_Test is Base_Test {
    function test_MethodList() external {
        bytes4[] memory functionSig = new bytes4[](1);
        functionSig[0] = ISablierV2LockupSender.onStreamCanceled.selector;

        bytes4[] memory actualMethodList = target.methodList();
        bytes4[] memory expectedMethodList = functionSig;
        assertEq(actualMethodList, expectedMethodList, "method list does not match");
    }
}
