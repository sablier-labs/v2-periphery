// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Errors } from "@sablier/v2-core/libraries/Errors.sol";

import { Integration_Test } from "../../Integration.t.sol";

contract Unlist_Integration_Test is Integration_Test {
    function test_RevertWhen_CallerNotAdmin() external {
        changePrank({ msgSender: users.eve.addr });
        vm.expectRevert(abi.encodeWithSelector(Errors.CallerNotAdmin.selector, users.admin.addr, users.eve.addr));
        archive.unlist(address(linear));
    }

    modifier callerAdmin() {
        changePrank({ msgSender: users.admin.addr });
        _;
    }

    function test_Unlist_AddressNotListed() external callerAdmin {
        bool isListed = archive.isListed(address(linear));
        assertFalse(isListed, "isListed");
    }

    modifier addressListed() {
        _;
    }

    function test_Unlist() external callerAdmin addressListed {
        archive.list(address(linear));
        archive.unlist(address(linear));
        bool isListed = archive.isListed(address(linear));
        assertFalse(isListed, "isListed");
    }
}
