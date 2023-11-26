// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

/// @title Errors
/// @notice Library containing all custom errors the protocol may revert with.
library Errors {
    /*//////////////////////////////////////////////////////////////////////////
                                      GENERICS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when trying to perform a standard call to a function that allows only delegate calls.
    error CallNotDelegateCall();

    /*//////////////////////////////////////////////////////////////////////////
                                SABLIER-V2-BATCH
    //////////////////////////////////////////////////////////////////////////*/

    error SablierV2Batch_BatchSizeZero();

    /*//////////////////////////////////////////////////////////////////////////
                             SABLIER-V2-MERKLE-STREAMER
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when trying to claim after the campaign has expired.
    error SablierV2MerkleStreamer_CampaignExpired(uint256 currentTime, uint40 expiration);

    /// @notice Thrown when trying to clawback when the campaign has not expired.
    error SablierV2MerkleStreamer_CampaignNotExpired(uint256 currentTime, uint40 expiration);

    /// @notice Thrown when trying to claim with an invalid Merkle proof.
    error SablierV2MerkleStreamer_InvalidProof();

    /// @notice Thrown when trying to claim when the protocol fee is not zero.
    error SablierV2MerkleStreamer_ProtocolFeeNotZero();

    /// @notice Thrown when trying to claim the same stream more than once.
    error SablierV2MerkleStreamer_StreamClaimed(uint256 index);

    /*//////////////////////////////////////////////////////////////////////////
                              SABLIER-V2-PROXY-TARGET
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when trying to perform an action that requires the batch size to not be zero.
    error SablierV2ProxyTarget_BatchSizeZero();

    /// @notice Thrown when trying to wrap and create a stream and the credit amount is not equal to `msg.value`.
    error SablierV2ProxyTarget_CreditAmountMismatch(uint256 msgValue, uint256 creditAmount);
}
