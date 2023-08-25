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
                                SABLIER-V2-AIRSTREAM
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when trying to claim multiple times.
    error SablierV2AirstreamCampaign_AlreadyClaimed(uint256 index);

    /// @notice Thrown when trying to clawback when airstream campaign has expired.
    error SablierV2AirstreamCampaign_CampaignHasExpired(uint256 currentTime, uint40 expiration);

    /// @notice Thrown when trying to claim when airstream campaign has not expired.
    error SablierV2AirstreamCampaign_CampaignHasNotExpired(uint256 currentTime, uint40 expiration);

    /// @notice Thrown when trying to claim with invalid Merkle proof.
    error SablierV2AirstreamCampaign_InvalidProof();

    /*//////////////////////////////////////////////////////////////////////////
                              SABLIER-V2-PROXY-PLUGIN
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when the caller is an unknown address, which is not listed in the archive.
    error SablierV2ProxyPlugin_UnknownCaller(address caller);

    /*//////////////////////////////////////////////////////////////////////////
                              SABLIER-V2-PROXY-TARGET
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when trying to perform an action that requires the batch size to not be zero.
    error SablierV2ProxyTarget_BatchSizeZero();

    /// @notice Thrown when trying to wrap and create a stream and the credit amount is not equal to `msg.value`.
    error SablierV2ProxyTarget_CreditAmountMismatch(uint256 msgValue, uint256 creditAmount);
}
