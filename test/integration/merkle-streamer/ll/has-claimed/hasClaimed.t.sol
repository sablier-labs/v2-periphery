// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { MerkleStreamer_Integration_Test } from "../../MerkleStreamer.t.sol";

contract HasClaimed_Integration_Test is MerkleStreamer_Integration_Test {
    function setUp() public virtual override {
        MerkleStreamer_Integration_Test.setUp();
    }

    function test_HasClaimed_IndexNotInTree() external {
        uint256 indexNotInTree = 1337e18;
        assertFalse(merkleStreamerLL.hasClaimed(indexNotInTree), "claimed");
    }

    modifier whenIndexInTree() {
        _;
    }

    function test_HasClaimed_NotClaimed() external whenIndexInTree {
        assertFalse(merkleStreamerLL.hasClaimed(defaults.INDEX1()), "claimed");
    }

    modifier givenRecipientHasClaimed() {
        claimLL();
        _;
    }

    function test_HasClaimed() external whenIndexInTree givenRecipientHasClaimed {
        assertTrue(merkleStreamerLL.hasClaimed(defaults.INDEX1()), "not claimed");
    }
}
