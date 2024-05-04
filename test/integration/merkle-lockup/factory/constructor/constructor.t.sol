// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { SablierV2MerkleLockupFactory } from "src/SablierV2MerkleLockupFactory.sol";

import { MerkleLockup_Integration_Test } from "../../MerkleLockup.t.sol";

contract Constructor_BatchLockup_Integration_Test is MerkleLockup_Integration_Test {
    function setUp() public virtual override {
        MerkleLockup_Integration_Test.setUp();
    }

    function test_Constructor() external {
        vm.expectEmit();
        emit TransferAdmin({ oldAdmin: address(0), newAdmin: users.admin });
        SablierV2MerkleLockupFactory merkleLockupFactory = new SablierV2MerkleLockupFactory(users.admin);

        address actualAdmin = merkleLockupFactory.admin();
        address expectedAdmin = users.admin;
        assertEq(actualAdmin, expectedAdmin, "admin mismatch");
    }
}
