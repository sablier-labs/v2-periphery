// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Integration_Test } from "../../../Integration.t.sol";

contract HasClaimed_Integration_Test is Integration_Test {
    function setUp() public virtual override {
        Integration_Test.setUp();
    }

    function test_HasClaimed_IndexNotInTree() external {
        uint256 indexNotInTree = 1337e18;
        assertFalse(campaignLL.hasClaimed(indexNotInTree), "claimed");
    }

    modifier whenIndexInTree() {
        _;
    }

    function test_HasClaimed_NotClaimed() external whenIndexInTree {
        assertFalse(campaignLL.hasClaimed(defaults.INDEX1()), "claimed");
    }

    modifier whenRecipientHasClaimed() {
        _;
    }

    function test_HasClaimed() external whenIndexInTree whenRecipientHasClaimed {
        claimLL();
        assertTrue(campaignLL.hasClaimed(defaults.INDEX1()), "not claimed");
    }
}
