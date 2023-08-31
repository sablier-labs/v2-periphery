// SPDX-License-Identifier: GPL-3.0-or-later
// solhint-disable reason-string
pragma solidity >=0.8.19;

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
        require(count == recipient.length && count == amount.length, "Merkle leaves arrays must have the same length");
        leaves = new bytes32[](count);
        for (uint256 i = 0; i < count; ++i) {
            leaves[i] = computeLeaf(indexes[i], recipient[i], amount[i]);
        }
    }
}
