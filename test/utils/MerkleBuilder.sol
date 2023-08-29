// SPDX-License-Identifier: GPL-3.0-or-later
// solhint-disable reason-string
pragma solidity >=0.8.19;

import { msb } from "@prb/math/src/Common.sol";

/// @dev A helper library for building Merkle leaves, roots, and proofs.
library MerkleBuilder {
    /// @dev Function that hashes together the data needed for a Merkle tree leaf.
    function computeLeaf(uint256 index, address recipient, uint128 amount) internal pure returns (bytes32 leaf) {
        leaf = keccak256(abi.encodePacked(index, recipient, amount));
    }

    /// @dev A batch function for `computeLeaf`.
    function computeLeaves(
        uint256[] memory indexes,
        address[] memory recipient,
        uint128[] memory amount
    )
        internal
        pure
        returns (bytes32[] memory leaves)
    {
        uint256 count = indexes.length;
        require(count == recipient.length && count == amount.length, "Input arrays must have the same length");
        leaves = new bytes32[](count);
        for (uint256 i = 0; i < count; ++i) {
            leaves[i] = computeLeaf(indexes[i], recipient[i], amount[i]);
        }
    }

    /// @dev Function that computes the Merkle proof for a leaf position in the Merkle tree.
    //
    // Let's take for example the following Merkle tree with 4 leaves:
    //
    //        ROOT
    //      /      \
    //    H01      H23
    //   /  \     /  \
    // L0   L1   L2   L3
    //
    // If the `leafPos` is 0 (L0), the function will return the Merkle proof [L1, H23].
    function computeProof(bytes32[] memory leaves, uint256 leafPos) internal pure returns (bytes32[] memory) {
        uint256 count = leaves.length;
        require(count > 1, "leaves length must be greater than one");

        // `log2Ceil` is the ceil value of the binary logarithm of the number of leaves in the tree.
        uint256 log2Ceil;

        // Calculate the most significant bit of the leaves length, which is the floor value of log2(count).
        uint256 _msb = msb(count);

        // Calculate the least significant bit using the bitwise inverse operator ~.
        uint256 _lsb = (~count + 1) & count;

        // If the count is a power of 2 and msb is greater than 0, then log2Ceil is exactly the msb.
        // Otherwise, we need to take the ceiling value by adding 1 to msb.
        if ((_lsb == count) && (_msb > 0)) {
            log2Ceil = _msb;
        } else {
            log2Ceil = _msb + 1;
        }

        // `log2Ceil` is the exact depth of the Merkle tree, so the proof must be this length.
        bytes32[] memory proof = new bytes32[](log2Ceil);
        uint256 pos = 0;
        while (leaves.length > 1) {
            unchecked {
                if (leafPos % 2 == 1) {
                    proof[pos] = leaves[leafPos - 1];
                } else if (leafPos + 1 == leaves.length) {
                    proof[pos] = bytes32(0);
                } else {
                    proof[pos] = leaves[leafPos + 1];
                }
                ++pos;
                leafPos /= 2;
            }
            leaves = combineLeaves(leaves);
        }
        return proof;
    }

    /// @dev Function that computes the Merkle root for a set of leaves.
    function computeRoot(bytes32[] memory leaves) internal pure returns (bytes32) {
        require(leaves.length > 1, "leaves length must be greater than one");
        while (leaves.length > 1) {
            leaves = combineLeaves(leaves);
        }
        return leaves[0];
    }

    /// @dev Function that returns the hash of two `bytes32`.
    function hashBytes32(bytes32 b1, bytes32 b2) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(b1, b2));
    }

    /// @dev Function that hashes the two `bytes32` inputs in ascending order.
    function hashPair(bytes32 left, bytes32 right) internal pure returns (bytes32 pair) {
        pair = left < right ? hashBytes32(left, right) : hashBytes32(right, left);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                 PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Function that takes an array of leaves and combines them to create the next level of the Merkle tree.
    function combineLeaves(bytes32[] memory leaves) private pure returns (bytes32[] memory) {
        uint256 count = leaves.length;
        bytes32[] memory result = new bytes32[]((count + 1) / 2);
        for (uint256 i = 0; i < count; i += 2) {
            bytes32 left = leaves[i];
            bytes32 right = i + 1 < count ? leaves[i + 1] : bytes32(0);
            result[i / 2] = hashPair(left, right);
        }
        return result;
    }
}
