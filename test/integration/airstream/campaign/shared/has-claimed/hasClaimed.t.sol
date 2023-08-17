// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Integration_Test } from "../../../../Integration.t.sol";

abstract contract HasClaimed_Integration_Test is Integration_Test {
    function setUp() public virtual override { }

    function test_HasClaimed_IndexNotInTree() external {
        uint256 indexNotInTree = 1337;
        assertFalse(campaign.hasClaimed(indexNotInTree));
    }

    modifier whenIndexInTree() {
        _;
    }

    function test_HasClaimed_NotClaimed() external whenIndexInTree {
        assertFalse(campaign.hasClaimed(defaults.INDEX1()));
    }

    function test_HasClaimed() external whenIndexInTree {
        claim();
        assertTrue(campaign.hasClaimed(defaults.INDEX1()));
    }
}
