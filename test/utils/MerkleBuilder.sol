// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { msb } from "@prb/math/Common.sol";

library MerkleBuilder {
    function computeLeaf(uint256 index, address recipient, uint128 amount) internal pure returns (bytes32 leaf) {
        leaf = keccak256(abi.encodePacked(index, recipient, amount));
    }

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

    function computeProof(bytes32[] memory data, uint256 node) public pure returns (bytes32[] memory) {
        uint256 count = data.length;
        require(count > 1, "Data length must be greater than one");

        uint256 log2Ceil;
        uint256 _msb = msb(count);
        uint256 _lsb = (~count + 1) & count;
        if ((_lsb == count) && (_msb > 0)) {
            log2Ceil = _msb;
        } else {
            log2Ceil = _msb + 1;
        }

        bytes32[] memory proof = new bytes32[](log2Ceil);
        uint256 pos = 0;
        while (data.length > 1) {
            unchecked {
                if (node % 2 == 1) {
                    proof[pos] = data[node - 1];
                } else if (node + 1 == data.length) {
                    proof[pos] = bytes32(0);
                } else {
                    proof[pos] = data[node + 1];
                }
                ++pos;
                node /= 2;
            }
            data = combineLeaves(data);
        }
        return proof;
    }

    function computeRoot(bytes32[] memory data) public pure returns (bytes32) {
        require(data.length > 1, "Data length must be greater than one");
        while (data.length > 1) {
            data = combineLeaves(data);
        }
        return data[0];
    }

    /// @dev Helper function that returns the hash of two `bytes32`.
    function hashBytes32(bytes32 b1, bytes32 b2) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(b1, b2));
    }

    /// @dev Helper function that hashes the two `bytes32` inputs in ascending order.
    function hashPair(bytes32 left, bytes32 right) internal pure returns (bytes32 pair) {
        pair = left < right ? hashBytes32(left, right) : hashBytes32(right, left);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                 PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function combineLeaves(bytes32[] memory data) private pure returns (bytes32[] memory) {
        uint256 count = data.length;
        bytes32[] memory result = new bytes32[]((count + 1) / 2);
        for (uint256 i = 0; i < count; i += 2) {
            bytes32 left = data[i];
            bytes32 right = i + 1 < count ? data[i + 1] : bytes32(0);
            result[i / 2] = hashPair(left, right);
        }
        return result;
    }
}
