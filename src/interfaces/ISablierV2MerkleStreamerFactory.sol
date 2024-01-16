// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { ISablierV2MerkleStreamerLL } from "./ISablierV2MerkleStreamerLL.sol";
import { MerkleStreamerFactory } from "../types/DataTypes.sol";

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
        string name,
        ISablierV2LockupLinear indexed lockupLinear,
        IERC20 indexed asset,
        bytes32 merkleRoot,
        uint40 expiration,
        LockupLinear.Durations streamDurations,
        bool cancelable,
        bool transferable,
        string ipfsCID,
        uint256 aggregateAmount,
        uint256 recipientsCount
    );

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Creates a new Merkle streamer that uses Lockup Linear.
    /// @dev Emits a {CreateMerkleStreamerLL} event.
    /// @param params Struct encapsulating the function parameters, which are documented in {DataTypes}.
    /// @return merkleStreamerLL The address of the newly created Merkle streamer contract.
    function createMerkleStreamerLL(MerkleStreamerFactory.CreateLL memory params)
        external
        returns (ISablierV2MerkleStreamerLL merkleStreamerLL);
}
