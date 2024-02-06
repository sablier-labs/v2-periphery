// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { ISablierV2LockupDynamic } from "@sablier/v2-core/src/interfaces/ISablierV2LockupDynamic.sol";
import { LockupDynamic } from "@sablier/v2-core/src/types/DataTypes.sol";

import { ISablierV2MerkleLockup } from "./ISablierV2MerkleLockup.sol";

/// @title ISablierV2MerkleLockupLD
/// @notice Merkle Lockup that creates Lockup Dynamic streams.
interface ISablierV2MerkleLockupLD is ISablierV2MerkleLockup {
    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice The address of the {SablierV2LockupDynamic} contract.
    function LOCKUP_DYNAMIC() external view returns (ISablierV2LockupDynamic);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Makes the claim by creating a Lockup Dynamic stream to the recipient.
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
    /// @param segments The segments with durations to create the custom streaming curve.
    /// @param merkleProof The Merkle proof of inclusion in the stream.
    /// @return streamId The id of the newly created stream.
    function claim(
        uint256 index,
        address recipient,
        uint128 amount,
        LockupDynamic.SegmentWithDuration[] memory segments,
        bytes32[] calldata merkleProof
    )
        external
        returns (uint256 streamId);
}
