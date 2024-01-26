// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

/// @title Errors
/// @notice Library containing all custom errors the protocol may revert with.
library Errors {
    /*//////////////////////////////////////////////////////////////////////////
                                SABLIER-V2-BATCH
    //////////////////////////////////////////////////////////////////////////*/

    error SablierV2Batch_BatchSizeZero();

    /*//////////////////////////////////////////////////////////////////////////
                             SABLIER-V2-MERKLE-STREAMER
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when trying to claim after the campaign has expired.
    error SablierV2MerkleStreamer_CampaignExpired(uint256 currentTime, uint40 expiration);

    /// @notice Thrown when trying to create a campaign with a name that is too long.
    error SablierV2MerkleStreamer_CampaignNameTooLong(uint256 nameLength, uint256 maxLength);

    /// @notice Thrown when trying to clawback when the campaign has not expired.
    error SablierV2MerkleStreamer_CampaignNotExpired(uint256 currentTime, uint40 expiration);

    /// @notice Thrown when trying to claim with an invalid Merkle proof.
    error SablierV2MerkleStreamer_InvalidProof();

    /// @notice Thrown when trying to claim the same stream more than once.
    error SablierV2MerkleStreamer_StreamClaimed(uint256 index);
}
