// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { ISablierV2MerkleStreamerFactory } from "./interfaces/ISablierV2MerkleStreamerFactory.sol";
import { ISablierV2MerkleStreamer } from "./interfaces/ISablierV2MerkleStreamer.sol";
import { ISablierV2MerkleStreamerLL } from "./interfaces/ISablierV2MerkleStreamerLL.sol";
import { SablierV2MerkleStreamerLL } from "./SablierV2MerkleStreamerLL.sol";

/// @title SablierV2MerkleStreamerFactory
/// @notice See the documentation in {ISablierV2MerkleStreamerFactory}.
contract SablierV2MerkleStreamerFactory is ISablierV2MerkleStreamerFactory {
    /*//////////////////////////////////////////////////////////////////////////
                                  INTERNAL STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice The list of Merkle streamers created by the admin.
    mapping(address admin => ISablierV2MerkleStreamer[] contracts) private _merkleStreamers;

    /*//////////////////////////////////////////////////////////////////////////
                           USER-FACING CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice inheritdoc ISablierV2MerkleStreamerFactory
    function getMerkleStreamers(address admin)
        external
        view
        override
        returns (ISablierV2MerkleStreamer[] memory merkleStreamers)
    {
        merkleStreamers = _merkleStreamers[admin];
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice inheritdoc ISablierV2MerkleStreamerFactory
    function createMerkleStreamerLL(
        address initialAdmin,
        ISablierV2LockupLinear lockupLinear,
        IERC20 asset,
        bytes32 merkleRoot,
        uint40 expiration,
        LockupLinear.Durations memory streamDurations,
        bool cancelable,
        string memory ipfsCID,
        uint256 aggregateAmount,
        uint256 recipientsCount
    )
        external
        returns (ISablierV2MerkleStreamerLL merkleStreamerLL)
    {
        // Hash the parameters to generate a salt.
        bytes32 salt = keccak256(abi.encodePacked(initialAdmin, lockupLinear, asset, merkleRoot, expiration));

        // Deploy the Merkle streamer with CREATE2.
        merkleStreamerLL = new SablierV2MerkleStreamerLL{salt: salt} (
            initialAdmin,
            lockupLinear,
            asset,
            merkleRoot,
            expiration,
            streamDurations,
            cancelable
        );

        // Effects: append the streamer in the admin's list.
        _merkleStreamers[initialAdmin].push(merkleStreamerLL);

        // Log the creation of the Merkle streamer, including some metadata that is not stored on-chain.
        emit CreateMerkleStreamerLL(
            merkleStreamerLL,
            initialAdmin,
            lockupLinear,
            asset,
            expiration,
            streamDurations,
            cancelable,
            ipfsCID,
            aggregateAmount,
            recipientsCount
        );
    }
}
