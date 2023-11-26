// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";

import { ISablierV2MerkleStreamer } from "./ISablierV2MerkleStreamer.sol";

/// @title ISablierV2MerkleStreamerLL
/// @notice Merkle streamer that creates Lockup Linear streams.
interface ISablierV2MerkleStreamerLL is ISablierV2MerkleStreamer {
    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice The address of the {SablierV2LockupLinear} contract.
    function LOCKUP_LINEAR() external view returns (ISablierV2LockupLinear);

    /// @notice The total streaming duration of each stream.
    function streamDurations() external view returns (uint40 cliff, uint40 duration);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Makes the claim by creating a Lockup Linear stream to the recipient.
    ///
    /// @dev Emits a {Claim} event.
    ///
    /// Requirements:
    /// - The campaign must not have expired.
    /// - The stream must not have been claimed already.
    /// - The protocol fee must be zero.
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
