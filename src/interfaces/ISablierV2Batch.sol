// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ISablierV2LockupDynamic } from "@sablier/v2-core/src/interfaces/ISablierV2LockupDynamic.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";

import { Batch } from "../types/DataTypes.sol";

/// @title ISablierV2Batch
/// @notice Helper to batch create Sablier V2 Lockup streams.
interface ISablierV2Batch {
    /*//////////////////////////////////////////////////////////////////////////
                              SABLIER-V2-LOCKUP-LINEAR
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Creates a batch of Lockup Linear streams using `createWithDurations`.
    ///
    /// @dev Requirements:
    /// - There must be at least one element in `batch`.
    /// - All requirements from {ISablierV2LockupLinear.createWithDurations} must be met for each stream.
    ///
    /// @param lockupLinear The address of the {SablierV2LockupLinear} contract.
    /// @param asset The contract address of the ERC-20 asset used for streaming.
    /// @param batch An array of structs, each encapsulating a subset of the parameters of
    /// {SablierV2LockupLinear.createWithDurations}.
    /// @return streamIds The ids of the newly created streams.
    function createWithDurations(
        ISablierV2LockupLinear lockupLinear,
        IERC20 asset,
        Batch.CreateWithDurations[] calldata batch
    )
        external
        returns (uint256[] memory streamIds);

    /// @notice Creates a batch of Lockup Linear streams using `createWithRange`.
    ///
    /// @dev Requirements:
    /// - There must be at least one element in `batch`.
    /// - All requirements from {ISablierV2LockupLinear.createWithRange} must be met for each stream.
    ///
    /// @param lockupLinear The address of the {SablierV2LockupLinear} contract.
    /// @param asset The contract address of the ERC-20 asset used for streaming.
    /// @param batch An array of structs, each encapsulating a subset of the parameters of
    /// {SablierV2LockupLinear.createWithRange}.
    /// @return streamIds The ids of the newly created streams.
    function createWithRange(
        ISablierV2LockupLinear lockupLinear,
        IERC20 asset,
        Batch.CreateWithRange[] calldata batch
    )
        external
        returns (uint256[] memory streamIds);

    /*//////////////////////////////////////////////////////////////////////////
                             SABLIER-V2-LOCKUP-DYNAMIC
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Creates a batch of Lockup Dynamic streams using `createWithDeltas`.
    ///
    /// @dev Requirements:
    /// - There must be at least one element in `batch`.
    /// - All requirements from {ISablierV2LockupDynamic.createWithDeltas} must be met for each stream.
    ///
    /// @param lockupDynamic The address of the {SablierV2LockupDynamic} contract.
    /// @param asset The contract address of the ERC-20 asset used for streaming.
    /// @param batch An array of structs, each encapsulating a subset of the parameters of
    /// {SablierV2LockupDynamic.createWithDeltas}.
    /// @return streamIds The ids of the newly created streams.
    function createWithDeltas(
        ISablierV2LockupDynamic lockupDynamic,
        IERC20 asset,
        Batch.CreateWithDeltas[] calldata batch
    )
        external
        returns (uint256[] memory streamIds);

    /// @notice Creates a batch of Lockup Dynamic streams using `createWithMilestones`.
    ///
    /// @dev Requirements:
    /// - There must be at least one element in `batch`.
    /// - All requirements from {ISablierV2LockupDynamic.createWithMilestones} must be met for each stream.
    ///
    /// @param lockupDynamic The address of the {SablierV2LockupDynamic} contract.
    /// @param asset The contract address of the ERC-20 asset used for streaming.
    /// @param batch An array of structs, each encapsulating a subset of the parameters of
    /// {SablierV2LockupDynamic.createWithMilestones}.
    /// @return streamIds The ids of the newly created streams.
    function createWithMilestones(
        ISablierV2LockupDynamic lockupDynamic,
        IERC20 asset,
        Batch.CreateWithMilestones[] calldata batch
    )
        external
        returns (uint256[] memory streamIds);
}
