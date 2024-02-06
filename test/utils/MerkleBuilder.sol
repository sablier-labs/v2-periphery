// SPDX-License-Identifier: GPL-3.0-or-later
// solhint-disable reason-string
pragma solidity >=0.8.22;

import { LockupDynamic } from "@sablier/v2-core/src/types/DataTypes.sol";
import { LibSort } from "solady/src/utils/LibSort.sol";

/// @dev A helper library for building Merkle leaves, roots, and proofs.
library MerkleBuilder {
    /*//////////////////////////////////////////////////////////////////////////
                                  MERKLE-LEAF-LD
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Function that double hashes the data needed for a Merkle tree leaf in Lockup Dynamic.
    function computeLeafLD(
        uint256 index,
        address recipient,
        uint128 amount,
        LockupDynamic.SegmentWithDuration[] memory segments
    )
        internal
        pure
        returns (uint256 leaf)
    {
        leaf = uint256(keccak256(bytes.concat(keccak256(abi.encode(index, recipient, amount, segments)))));
    }

    /// @dev A batch function for `computeLeafLD`.
    function computeLeavesLD(
        uint256[] memory indexes,
        address[] memory recipients,
        uint128[] memory amounts,
        LockupDynamic.SegmentWithDuration[][] memory segments
    )
        internal
        pure
        returns (uint256[] memory leaves)
    {
        uint256 count = indexes.length;
        require(
            count == recipients.length && count == amounts.length && count == segments.length,
            "Merkle leaves arrays must have the same length"
        );
        leaves = new uint256[](count);
        for (uint256 i = 0; i < count; ++i) {
            leaves[i] = computeLeafLD(indexes[i], recipients[i], amounts[i], segments[i]);
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  MERKLE-LEAF-LL
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Function that double hashes the data needed for a Merkle tree leaf in Lockup Linear.
    function computeLeafLL(uint256 index, address recipient, uint128 amount) internal pure returns (uint256 leaf) {
        leaf = uint256(keccak256(bytes.concat(keccak256(abi.encode(index, recipient, amount)))));
    }

    /// @dev A batch function for `computeLeafLL`.
    function computeLeavesLL(
        uint256[] memory indexes,
        address[] memory recipients,
        uint128[] memory amounts
    )
        internal
        pure
        returns (uint256[] memory leaves)
    {
        uint256 count = indexes.length;
        require(count == recipients.length && count == amounts.length, "Merkle leaves arrays must have the same length");
        leaves = new uint256[](count);
        for (uint256 i = 0; i < count; ++i) {
            leaves[i] = computeLeafLL(indexes[i], recipients[i], amounts[i]);
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Function that convert a storage array to memory and sorts it in ascending order. We need this
    /// because `LibSort` does not support storage arrays.
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
    function toBytes32(uint256[] storage arr_) internal view returns (bytes32[] memory arr) {
        arr = new bytes32[](arr_.length);
        for (uint256 i = 0; i < arr_.length; ++i) {
            arr[i] = bytes32(arr_[i]);
        }
    }
}
