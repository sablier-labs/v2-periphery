// SPDX-License-Identifier: GPL-3.0-or-later
// solhint-disable reason-string
pragma solidity >=0.8.19;

/// @dev A helper library for building Merkle leaves, roots, and proofs.
library MerkleBuilder {
    /// @dev Function that hashes together the data needed for a Merkle tree leaf.
    function computeLeaf(uint256 index, address recipient, uint128 amount) internal pure returns (bytes32 leaf) {
        leaf = keccak256(bytes.concat(keccak256(abi.encode(index, recipient, amount))));
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

    /// @dev Function that binary searchs the position of a specific leaf in a sorted `bytes32` array.
    function binarySearch(bytes32[] memory arr, bytes32 val) internal pure returns (uint256) {
        uint256 low = 0;
        uint256 high = arr.length - 1;
        uint256 mid;

        while (low <= high) {
            mid = low + (high - low) / 2;

            if (arr[mid] == val) {
                return mid;
            }

            if (arr[mid] < val) {
                low = mid + 1;
            } else {
                if (mid == 0) {
                    break;
                }
                high = mid - 1;
            }
        }

        return mid;
    }

    /// @dev Function that sorts an array of `bytes32` in ascending order.
    function sort(bytes32[] memory arr) internal pure returns (bytes32[] memory) {
        _quickSort(arr, 0, arr.length - 1);
        return arr;
    }

    function _quickSort(bytes32[] memory arr, uint256 i, uint256 j) private pure {
        if (i < j) {
            uint256 p = _partition(arr, i, j);
            if (p > 0) {
                _quickSort(arr, i, p - 1);
            }
            _quickSort(arr, p + 1, j);
        }
    }

    function _partition(bytes32[] memory arr, uint256 i, uint256 j) private pure returns (uint256) {
        bytes32 pivot = arr[j];
        uint256 low = i;
        for (uint256 k = i; k < j; ++k) {
            if (arr[k] < pivot) {
                _swap(arr, low, k);
                ++low;
            }
        }
        _swap(arr, low, j);
        return low;
    }

    function _swap(bytes32[] memory arr, uint256 i, uint256 j) private pure {
        (arr[i], arr[j]) = (arr[j], arr[i]);
    }
}
