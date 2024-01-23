// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";

import { SablierV2MerkleStreamerLL } from "./SablierV2MerkleStreamerLL.sol";
import { ISablierV2MerkleStreamerFactory } from "./interfaces/ISablierV2MerkleStreamerFactory.sol";
import { ISablierV2MerkleStreamerLL } from "./interfaces/ISablierV2MerkleStreamerLL.sol";
import { MerkleStreamer } from "./types/DataTypes.sol";

/// @title SablierV2MerkleStreamerFactory
/// @notice See the documentation in {ISablierV2MerkleStreamerFactory}.
contract SablierV2MerkleStreamerFactory is ISablierV2MerkleStreamerFactory {
    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice inheritdoc ISablierV2MerkleStreamerFactory
    function createMerkleStreamerLL(
        MerkleStreamer.ConstructorParams memory params,
        ISablierV2LockupLinear lockupLinear,
        LockupLinear.Durations memory streamDurations,
        string memory ipfsCID,
        uint256 aggregateAmount,
        uint256 recipientsCount
    )
        external
        returns (ISablierV2MerkleStreamerLL merkleStreamerLL)
    {
        // Hash the parameters to generate a salt.
        bytes32 salt = keccak256(
            abi.encodePacked(
                params.initialAdmin,
                params.asset,
                bytes32(abi.encodePacked(params.name)),
                params.merkleRoot,
                params.expiration,
                params.cancelable,
                params.transferable,
                lockupLinear,
                abi.encode(streamDurations)
            )
        );

        // Deploy the Merkle streamer with CREATE2.
        merkleStreamerLL = new SablierV2MerkleStreamerLL{ salt: salt }(params, lockupLinear, streamDurations);

        // Using a different function to emit the event to avoid stack too deep error.
        emit CreateMerkleStreamerLL(
            merkleStreamerLL, params, lockupLinear, streamDurations, ipfsCID, aggregateAmount, recipientsCount
        );
    }
}
