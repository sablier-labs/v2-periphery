// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Errors } from "@sablier/v2-core/libraries/Errors.sol";

import { Unit_Test } from "../../Unit.t.sol";

contract Unlist_Unit_Test is Unit_Test {
    function test_RevertWhen_CallerNotAdmin() external {
        changePrank({ msgSender: users.eve.addr });
        vm.expectRevert(abi.encodeWithSelector(Errors.CallerNotAdmin.selector, users.admin.addr, users.eve.addr));
        chainLog.unlist(address(linear));
    }

    modifier callerAdmin() {
        changePrank({ msgSender: users.admin.addr });
        _;
    }

    function test_Unlist_AddressNotListed() external callerAdmin {
        bool isListed = chainLog.isListed(address(linear));
        assertFalse(isListed, "isListed");
    }

    modifier addressListed() {
        _;
    }

    function test_Unlist() external callerAdmin addressListed {
        chainLog.list(address(linear));
        chainLog.unlist(address(linear));
        bool isListed = chainLog.isListed(address(linear));
        assertFalse(isListed, "isListed");
    }
}
