// SPDX-License-Identifier: GPL-3.0-or-later
// solhint-disable reason-string
pragma solidity >=0.8.19;

import { LibSort } from "solady/utils/LibSort.sol";

/// @dev A helper library for building Merkle leaves, roots, and proofs.
library MerkleBuilder {
    /// @dev Function that hashes together the data needed for a Merkle tree leaf.
    function computeLeaf(uint256 index, address recipient, uint128 amount) internal pure returns (uint256 leaf) {
        leaf = uint256(keccak256(bytes.concat(keccak256(abi.encode(index, recipient, amount)))));
    }

    /// @dev A batch function for `computeLeaf`.
    function computeLeaves(
        uint256[] memory indexes,
        address[] memory recipient,
        uint128[] memory amount
    )
        internal
        pure
        returns (uint256[] memory leaves)
    {
        uint256 count = indexes.length;
        require(count == recipient.length && count == amount.length, "Merkle leaves arrays must have the same length");
        leaves = new uint256[](count);
        for (uint256 i = 0; i < count; ++i) {
            leaves[i] = computeLeaf(indexes[i], recipient[i], amount[i]);
        }
    }

    /// @dev Function that sorts a storage array of `uint256` in ascending order. We need this function because
    /// `LibSort` does not support storage arrays.
    function sortLeaves(uint256[] storage leaves) internal {
        uint256 leavesCount = leaves.length;

        // Declare the memory array.
        uint256[] memory _leaves = new uint256[](leavesCount);
        for (uint256 i = 0; i < leavesCount; ++i) {
            _leaves[i] = leaves[i];
        }

        // Sort the memory array.
        LibSort.sort(_leaves);

        // Copy the memory array back to storage.
        for (uint256 i = 0; i < leavesCount; ++i) {
            leaves[i] = _leaves[i];
        }
    }

    /// @dev Function that converts an array of `uint256` to an array of `bytes32`.
    function toBytes32(uint256[] storage _arr) internal view returns (bytes32[] memory arr) {
        arr = new bytes32[](_arr.length);
        for (uint256 i = 0; i < _arr.length; ++i) {
            arr[i] = bytes32(_arr[i]);
        }
    }
}
