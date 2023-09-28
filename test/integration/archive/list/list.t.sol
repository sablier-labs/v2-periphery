// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Errors } from "@sablier/v2-core/src/libraries/Errors.sol";

import { Integration_Test } from "../../Integration.t.sol";

contract List_Integration_Test is Integration_Test {
    function test_RevertWhen_CallerNotAdmin() external {
        changePrank({ msgSender: users.eve.addr });
        vm.expectRevert(abi.encodeWithSelector(Errors.CallerNotAdmin.selector, users.admin.addr, users.eve.addr));
        archive.list(address(lockupLinear));
    }

    modifier whenCallerAdmin() {
        changePrank({ msgSender: users.admin.addr });
        _;
    }

    function test_List_AddressListed() external whenCallerAdmin {
        archive.list(address(lockupLinear));
        archive.list(address(lockupLinear));
        bool isListed = archive.isListed(address(lockupLinear));
        assertTrue(isListed, "isListed");
    }

    modifier givenAddressNotListed() {
        _;
    }

    function test_List() external whenCallerAdmin givenAddressNotListed {
        vm.expectEmit({ emitter: address(archive) });
        emit List({ admin: users.admin.addr, addr: address(lockupLinear) });
        archive.list(address(lockupLinear));
        bool isListed = archive.isListed(address(lockupLinear));
        assertTrue(isListed, "isListed");
    }
}
