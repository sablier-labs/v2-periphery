// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
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

    function testFuzz_ComputeProof(bytes32[] memory data, uint256 leafPos) external {
        vm.assume(data.length > 1);
        leafPos = _bound(leafPos, 1, data.length - 1);

        bytes32[] memory proof = MerkleBuilder.computeProof(data, leafPos);
        bytes32 root = MerkleBuilder.computeRoot(data);

        bytes32 leafToProve = data[leafPos];
        assertTrue(MerkleProof.verify(proof, root, leafToProve), "computeProof");
    }

    function testFuzz_ComputeRoot(bytes32[] memory data, uint256 leafPos) public {
        vm.assume(data.length > 1);
        leafPos = _bound(leafPos, 1, data.length - 1);

        bytes32[] memory proof = MerkleBuilder.computeProof(data, leafPos);
        bytes32 actualRoot = MerkleBuilder.computeRoot(data);

        bytes32 expectedRoot = data[leafPos];
        for (uint256 i = 0; i < proof.length; ++i) {
            expectedRoot = MerkleBuilder.hashPair(expectedRoot, proof[i]);
        }

        assertEq(actualRoot, expectedRoot, "computeRoot");
    }

    function testFuzz_HashBytes32(bytes32 b1, bytes32 b2) external {
        bytes32 actualHash = MerkleBuilder.hashBytes32(b1, b2);
        bytes32 expectedHash = keccak256(abi.encodePacked(b1, b2));
        assertEq(actualHash, expectedHash, "hashBytes32");
    }

    function testFuzz_HashPair(bytes32 left, bytes32 right) external {
        bytes32 actualHash = MerkleBuilder.hashPair(left, right);
        bytes32 expectedHash =
            left < right ? keccak256(abi.encodePacked(left, right)) : keccak256(abi.encodePacked(right, left));
        assertEq(actualHash, expectedHash, "hashPair");
    }
}
