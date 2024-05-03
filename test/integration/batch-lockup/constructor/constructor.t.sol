// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { SablierV2BatchLockup } from "src/SablierV2BatchLockup.sol";

import { Integration_Test } from "../../Integration.t.sol";

contract Constructor_BatchLockup_Integration_Test is Integration_Test {
    function setUp() public virtual override {
        Integration_Test.setUp();
    }

    function test_Constructor() external {
        vm.expectEmit();
        emit TransferAdmin({ oldAdmin: address(0), newAdmin: users.admin });
        SablierV2BatchLockup batchLockup = new SablierV2BatchLockup(users.admin);

        address actualAdmin = batchLockup.admin();
        address expectedAdmin = users.admin;
        assertEq(actualAdmin, expectedAdmin, "admin mismatch");
    }
}
