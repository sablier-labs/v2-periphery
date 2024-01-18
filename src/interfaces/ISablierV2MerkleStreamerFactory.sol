// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { ISablierV2MerkleStreamerLL } from "./ISablierV2MerkleStreamerLL.sol";
import { MerkleStreamer } from "../types/DataTypes.sol";

/// @title ISablierV2MerkleStreamerFactory
/// @notice Deploys new Lockup Linear Merkle streamers via CREATE2.
interface ISablierV2MerkleStreamerFactory {
    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a Sablier V2 Lockup Linear Merkle streamer is created.
    event CreateMerkleStreamerLL(
        ISablierV2MerkleStreamerLL merkleStreamer,
        address indexed admin,
        IERC20 indexed asset,
        string name,
        bytes32 merkleRoot,
        uint40 expiration,
        bool cancelable,
        bool transferable,
        ISablierV2LockupLinear indexed lockupLinear,
        LockupLinear.Durations streamDurations,
        string ipfsCID,
        uint256 aggregateAmount,
        uint256 recipientsCount
    );

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Creates a new Merkle streamer that uses Lockup Linear.
    /// @dev Emits a {CreateMerkleStreamerLL} event.
    /// @param params Struct encapsulating the {SablierV2MerkleStreamer} parameters, which are documented in
    /// {DataTypes}.
    /// @param lockupLinear The address of the {SablierV2LockupLinear} contract.
    /// @param streamDurations The durations for each stream due to the recipient.
    /// @param ipfsCID Metadata parameter emitted for indexing purposes.
    /// @param aggregateAmount Total amount of ERC-20 assets to be streamed to all recipients.
    /// @param recipientsCount Total number of recipients eligible to claim.
    /// @return merkleStreamerLL The address of the newly created Merkle streamer contract.
    function createMerkleStreamerLL(
        MerkleStreamer.ConstructorParams memory params,
        ISablierV2LockupLinear lockupLinear,
        LockupLinear.Durations memory streamDurations,
        string memory ipfsCID,
        uint256 aggregateAmount,
        uint256 recipientsCount
    )
        external
        returns (ISablierV2MerkleStreamerLL merkleStreamerLL);
}
