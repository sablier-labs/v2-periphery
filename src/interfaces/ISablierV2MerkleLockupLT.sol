// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { ISablierV2LockupTranched } from "@sablier/v2-core/src/interfaces/ISablierV2LockupTranched.sol";

import { ISablierV2MerkleLockup } from "./ISablierV2MerkleLockup.sol";
import { MerkleLockupLT } from "./../types/DataTypes.sol";

/// @title ISablierV2MerkleLockupLT
/// @notice Merkle Lockup that creates Lockup Tranched streams.
interface ISablierV2MerkleLockupLT is ISablierV2MerkleLockup {
    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Returns the tranches with their respective percentages and durations.
    function getTranchesWithPercentage() external view returns (MerkleLockupLT.TrancheWithPercentage[] memory);

    /// @notice The address of the {SablierV2LockupTranched} contract.
    function LOCKUP_TRANCHED() external view returns (ISablierV2LockupTranched);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Makes the claim by creating a Lockup Tranched stream to the recipient.
    ///
    /// @dev Emits a {Claim} event.
    ///
    /// Requirements:
    /// - The campaign must not have expired.
    /// - The stream must not have been claimed already.
    /// - The Merkle proof must be valid.
    ///
    /// @param index The index of the recipient in the Merkle tree.
    /// @param recipient The address of the stream holder.
    /// @param amount The amount of tokens to be streamed.
    /// @param merkleProof The Merkle proof of inclusion in the stream.
    /// @return streamId The id of the newly created stream.
    function claim(
        uint256 index,
        address recipient,
        uint128 amount,
        bytes32[] calldata merkleProof
    )
        external
        returns (uint256 streamId);
}
