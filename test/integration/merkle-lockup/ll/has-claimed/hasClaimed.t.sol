// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { MerkleLockup_Integration_Test } from "../../MerkleLockup.t.sol";

contract HasClaimed_Integration_Test is MerkleLockup_Integration_Test {
    function setUp() public virtual override {
        MerkleLockup_Integration_Test.setUp();
    }

    function test_HasClaimed_IndexNotInTree() external {
        uint256 indexNotInTree = 1337e18;
        assertFalse(merkleLockupLL.hasClaimed(indexNotInTree), "claimed");
    }

    modifier whenIndexInTree() {
        _;
    }

    function test_HasClaimed_NotClaimed() external whenIndexInTree {
        assertFalse(merkleLockupLL.hasClaimed(defaults.INDEX1()), "claimed");
    }

    modifier givenRecipientHasClaimed() {
        claimLL();
        _;
    }

    function test_HasClaimed() external whenIndexInTree givenRecipientHasClaimed {
        assertTrue(merkleLockupLL.hasClaimed(defaults.INDEX1()), "not claimed");
    }
}
