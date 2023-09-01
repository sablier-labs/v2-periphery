// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Errors } from "@sablier/v2-core/src/libraries/Errors.sol";

import { Integration_Test } from "../../Integration.t.sol";

contract Unlist_Integration_Test is Integration_Test {
    function test_RevertWhen_CallerNotAdmin() external {
        changePrank({ msgSender: users.eve.addr });
        vm.expectRevert(abi.encodeWithSelector(Errors.CallerNotAdmin.selector, users.admin.addr, users.eve.addr));
        archive.unlist(address(lockupLinear));
    }

    modifier whenCallerAdmin() {
        changePrank({ msgSender: users.admin.addr });
        _;
    }

    function test_Unlist_AddressNotListed() external whenCallerAdmin {
        archive.unlist(address(lockupLinear));
        bool isListed = archive.isListed(address(lockupLinear));
        assertFalse(isListed, "isListed");
    }

    modifier givenAddressListed() {
        archive.list(address(lockupLinear));
        _;
    }

    function test_Unlist() external whenCallerAdmin givenAddressListed {
        archive.unlist(address(lockupLinear));
        bool isListed = archive.isListed(address(lockupLinear));
        assertFalse(isListed, "isListed");
    }

    function test_Unlist_Event() external whenCallerAdmin givenAddressListed {
        vm.expectEmit({ emitter: address(archive) });
        emit Unlist({ admin: users.admin.addr, addr: address(lockupLinear) });
        archive.unlist(address(lockupLinear));
    }
}
