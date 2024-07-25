// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { ISablierV2MerkleLockup } from "./ISablierV2MerkleLockup.sol";

/// @title ISablierMerkleInstant
/// @notice MerkleLockup campaign that facilitates instant distribution of assets.
interface ISablierMerkleInstant is ISablierV2MerkleLockup {
    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a recipient claims an instant airdrop.
    event Claim(uint256 index, address indexed recipient, uint128 amount);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Makes the claim and transfer assets to the recipient.
    ///
    /// @dev Emits a {Claim} event.
    ///
    /// Requirements:
    /// - The campaign must not have expired.
    /// - The stream must not have been claimed already.
    /// - The Merkle proof must be valid.
    ///
    /// @param index The index of the recipient in the Merkle tree.
    /// @param recipient The address of the airdrop recipient.
    /// @param amount The amount of ERC-20 assets to be transferred to the recipient.
    /// @param merkleProof The proof of inclusion in the Merkle tree.
    function claim(uint256 index, address recipient, uint128 amount, bytes32[] calldata merkleProof) external;
}
