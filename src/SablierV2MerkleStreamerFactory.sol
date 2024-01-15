// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { ISablierV2MerkleStreamerFactory } from "./interfaces/ISablierV2MerkleStreamerFactory.sol";
import { ISablierV2MerkleStreamerLL } from "./interfaces/ISablierV2MerkleStreamerLL.sol";
import { SablierV2MerkleStreamerLL } from "./SablierV2MerkleStreamerLL.sol";
import { MerkleStreamer } from "./types/DataTypes.sol";

/// @title SablierV2MerkleStreamerFactory
/// @notice See the documentation in {ISablierV2MerkleStreamerFactory}.
contract SablierV2MerkleStreamerFactory is ISablierV2MerkleStreamerFactory {
    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice inheritdoc ISablierV2MerkleStreamerFactory
    function createMerkleStreamerLL(
        MerkleStreamer.CreateWithLockupLinear memory createLLParams,
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
                createLLParams.initialAdmin,
                createLLParams.lockupLinear,
                createLLParams.asset,
                bytes32(abi.encodePacked(createLLParams.name)),
                createLLParams.merkleRoot,
                createLLParams.expiration,
                abi.encode(createLLParams.streamDurations),
                createLLParams.cancelable,
                createLLParams.transferable
            )
        );

        // Deploy the Merkle streamer with CREATE2.
        merkleStreamerLL = new SablierV2MerkleStreamerLL{ salt: salt }(createLLParams);

        // Log the creation of the Merkle streamer, including some metadata that is not stored on-chain.
        emit CreateMerkleStreamerLL(
            merkleStreamerLL,
            createLLParams.initialAdmin,
            createLLParams.lockupLinear,
            createLLParams.asset,
            createLLParams.name,
            createLLParams.merkleRoot,
            createLLParams.expiration,
            createLLParams.streamDurations,
            createLLParams.cancelable,
            createLLParams.transferable,
            ipfsCID,
            aggregateAmount,
            recipientsCount
        );
    }
}
