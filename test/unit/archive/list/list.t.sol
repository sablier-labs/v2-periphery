// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Errors } from "@sablier/v2-core/libraries/Errors.sol";

import { Unit_Test } from "../../Unit.t.sol";

contract List_Unit_Test is Unit_Test {
    function test_RevertWhen_CallerNotAdmin() external {
        changePrank({ msgSender: users.eve.addr });
        vm.expectRevert(abi.encodeWithSelector(Errors.CallerNotAdmin.selector, users.admin.addr, users.eve.addr));
        archive.list(address(linear));
    }

    modifier callerAdmin() {
        changePrank({ msgSender: users.admin.addr });
        _;
    }

    function test_List_AddressListed() external callerAdmin {
        archive.list(address(linear));
        archive.list(address(linear));
        bool isListed = archive.isListed(address(linear));
        assertTrue(isListed, "isListed");
    }

    modifier addressNotListed() {
        _;
    }

    function test_List() external callerAdmin addressNotListed {
        archive.list(address(linear));
        bool isListed = archive.isListed(address(linear));
        assertTrue(isListed, "isListed");
    }
}
