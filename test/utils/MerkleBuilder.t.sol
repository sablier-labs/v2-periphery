// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { StdUtils } from "forge-std/StdUtils.sol";

import { MerkleBuilder } from "./MerkleBuilder.sol";

contract MerkleBuilder_Test is PRBTest, StdUtils {
    function testFuzz_ComputeLeaf(uint256 index, address recipient, uint128 amount) external {
        bytes32 actualLeaf = MerkleBuilder.computeLeaf(index, recipient, amount);
        bytes32 expectedLeaf = keccak256(abi.encodePacked(index, recipient, amount));
        assertEq(actualLeaf, expectedLeaf, "computeLeaf");
    }

    /// @dev We declare this struct so that we will not need cheatcodes in the `computeLeaves` test.
    struct LeavesParams {
        uint256 indexes;
        address recipients;
        uint128 amounts;
    }

    function testFuzz_ComputeLeaves(LeavesParams[] memory params) external {
        uint256 count = params.length;

        uint256[] memory indexes = new uint256[](count);
        address[] memory recipients = new address[](count);
        uint128[] memory amounts = new uint128[](count);
        for (uint256 i = 0; i < count; ++i) {
            indexes[i] = params[i].indexes;
            recipients[i] = params[i].recipients;
            amounts[i] = params[i].amounts;
        }

        bytes32[] memory actualLeaves = new bytes32[](count);
        actualLeaves = MerkleBuilder.computeLeaves(indexes, recipients, amounts);

        bytes32[] memory expectedLeaves = new bytes32[](count);
        for (uint256 i = 0; i < count; ++i) {
            expectedLeaves[i] = keccak256(abi.encodePacked(indexes[i], recipients[i], amounts[i]));
        }

        assertEq(actualLeaves, expectedLeaves, "computeLeaves");
    }
}
