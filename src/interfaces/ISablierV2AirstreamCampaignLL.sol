// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";

import { ISablierV2AirstreamCampaign } from "./ISablierV2AirstreamCampaign.sol";

/// @title ISablierV2AirstreamCampaignLL
/// @notice Manages the Lockup Linear campaign's claims.
interface ISablierV2AirstreamCampaignLL is ISablierV2AirstreamCampaign {
    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice The total streaming duration of each airstream.
    function airstreamDurations() external view returns (uint40 cliff, uint40 duration);

    /// @notice The address of the {SablierV2LockupLinear} contract.
    function lockupLinear() external view returns (ISablierV2LockupLinear);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Makes the claim by creating a Lockup Linear airstream to the recipient.
    ///
    /// @dev Emits a {Claim} event.
    ///
    /// Requirements:
    /// - The campaign must not have expired.
    /// - The airstream must not have been claimed already.
    /// - The Merkle proof must be valid.
    ///
    /// @param index The index of the recipient in the Merkle tree.
    /// @param recipient The address of the airstream holder.
    /// @param amount The amount of tokens to be airstreamed.
    /// @param merkleProof The Merkle proof of inclusion in the airstream.
    /// @return airstreamId The id of the newly created airstream.
    function claim(
        uint256 index,
        address recipient,
        uint128 amount,
        bytes32[] calldata merkleProof
    )
        external
        returns (uint256 airstreamId);
}
