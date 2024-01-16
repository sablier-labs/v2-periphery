// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { ISablierV2MerkleStreamerFactory } from "./interfaces/ISablierV2MerkleStreamerFactory.sol";
import { ISablierV2MerkleStreamerLL } from "./interfaces/ISablierV2MerkleStreamerLL.sol";
import { SablierV2MerkleStreamerLL } from "./SablierV2MerkleStreamerLL.sol";
import { Errors } from "./libraries/Errors.sol";
import { MerkleStreamerFactory } from "./types/DataTypes.sol";

/// @title SablierV2MerkleStreamerFactory
/// @notice See the documentation in {ISablierV2MerkleStreamerFactory}.
contract SablierV2MerkleStreamerFactory is ISablierV2MerkleStreamerFactory {
    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice inheritdoc ISablierV2MerkleStreamerFactory
    function createMerkleStreamerLL(MerkleStreamerFactory.CreateLL memory params)
        external
        returns (ISablierV2MerkleStreamerLL merkleStreamerLL)
    {
        // Checks: the campaign name is not greater than 32 bytes.
        if (bytes(params.name).length > 32) {
            revert Errors.SablierV2MerkleStreamerFactory_CampaignNameTooLong({
                nameLength: bytes(params.name).length,
                maxLength: 32
            });
        }

        // Convert the campaign name to bytes32.
        bytes32 nameBytes32 = bytes32(abi.encodePacked(params.name));

        // Hash the parameters to generate a salt.
        bytes32 salt = keccak256(
            abi.encodePacked(
                params.initialAdmin,
                nameBytes32,
                params.lockupLinear,
                params.asset,
                params.merkleRoot,
                params.expiration,
                abi.encode(params.streamDurations),
                params.cancelable,
                params.transferable
            )
        );

        // Deploy the Merkle streamer with CREATE2.
        merkleStreamerLL = new SablierV2MerkleStreamerLL{ salt: salt }(
            params.initialAdmin,
            nameBytes32,
            params.lockupLinear,
            params.asset,
            params.merkleRoot,
            params.expiration,
            params.streamDurations,
            params.cancelable,
            params.transferable
        );

        // Using a different function to emit the event to avoid stack too deep error.
        _emitLLEvent(merkleStreamerLL, params);
    }

    /*//////////////////////////////////////////////////////////////////////////
                          INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Helper function to emit the {CreateMerkleStreamerLL} event.
    function _emitLLEvent(
        ISablierV2MerkleStreamerLL merkleStreamerLL,
        MerkleStreamerFactory.CreateLL memory params
    )
        internal
    {
        // Log the creation of the Merkle streamer, including some metadata that is not stored on-chain.
        emit CreateMerkleStreamerLL(
            merkleStreamerLL,
            params.initialAdmin,
            params.name,
            params.lockupLinear,
            params.asset,
            params.merkleRoot,
            params.expiration,
            params.streamDurations,
            params.cancelable,
            params.transferable,
            params.ipfsCID,
            params.aggregateAmount,
            params.recipientsCount
        );
    }
}
