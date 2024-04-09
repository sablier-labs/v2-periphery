// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { UD2x18 } from "@prb/math/src/UD2x18.sol";

/// @title Errors
/// @notice Library containing all custom errors the protocol may revert with.
library Errors {
    /*//////////////////////////////////////////////////////////////////////////
                                SABLIER-V2-BATCH
    //////////////////////////////////////////////////////////////////////////*/

    error SablierV2Batch_BatchSizeZero();

    /*//////////////////////////////////////////////////////////////////////////
                             SABLIER-V2-MERKLE-LOCKUP
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when trying to claim after the campaign has expired.
    error SablierV2MerkleLockup_CampaignExpired(uint256 blockTimestamp, uint40 expiration);

    /// @notice Thrown when trying to create a campaign with a name that is too long.
    error SablierV2MerkleLockup_CampaignNameTooLong(uint256 nameLength, uint256 maxLength);

    /// @notice Thrown when trying to clawback when the campaign has not expired.
    error SablierV2MerkleLockup_CampaignNotExpired(uint256 blockTimestamp, uint40 expiration);

    /// @notice Thrown when trying to claim with an invalid Merkle proof.
    error SablierV2MerkleLockup_InvalidProof();

    /// @notice Thrown when trying to claim the same stream more than once.
    error SablierV2MerkleLockup_StreamClaimed(uint256 index);

    /*//////////////////////////////////////////////////////////////////////////
                          SABLIER-V2-MERKLE-LOCKUP-FACTORY
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when the sum of the tranches' unlock percentages does not equal 100%.
    error SablierV2MerkleLockupFactory_TotalPercentageNotEqualOneHundred(UD2x18 totalPercentage);
}
