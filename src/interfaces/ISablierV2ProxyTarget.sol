// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { ISablierV2Lockup } from "@sablier/v2-core/interfaces/ISablierV2Lockup.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";
import { ISablierV2LockupDynamic } from "@sablier/v2-core/interfaces/ISablierV2LockupDynamic.sol";
import { LockupLinear, LockupDynamic } from "@sablier/v2-core/types/DataTypes.sol";

import { Batch, Permit2Params } from "../types/DataTypes.sol";

/// @title ISablierV2ProxyTarget
/// @notice Proxy target contract with stateless scripts for interacting with Sablier V2 Core.
/// @dev Meant to be used with an instance of PRBProxy via DELEGATECALL.
interface ISablierV2ProxyTarget {
    /*//////////////////////////////////////////////////////////////////////////
                                 SABLIER-V2-LOCKUP
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Cancel multiple streams on each `lockup` contract.
    ///
    /// 1. Queries the proxy balances of each asset before the streams are canceled.
    /// 2. Performs multiple external calls on {SablierV2Lockup.cancelMultiple}.
    /// 3. Transfers the returned amounts of each asset to proxy owner, if greater than zero.
    ///
    /// @dev Notes:
    /// - The function assumes that the assets of the `params.streamIds` are the same as those in `assets` array.
    /// If any asset is missing, the returned amount will be left in the proxy contract.
    /// - See {ISablierV2Lockup.cancelMultiple} for documentation.
    /// - `params.lockup` should include {SablierV2LockupLinear} and {SablierV2LockupDynamic} contracts.
    ///
    /// @param params Struct that encapsulates the lockup contract and the stream ids.
    /// @param assets The contracts of the ERC-20 assets used for streaming.
    function batchCancelMultiple(Batch.CancelMultiple[] calldata params, IERC20[] calldata assets) external;

    /// @notice Target function to cancel a stream.
    ///
    /// @dev Notes:
    /// - See {ISablierV2Lockup.cancel} for documentation.
    /// - `lockup` can be either {SablierV2LockupLinear} or {SablierV2LockupDynamic} contract.
    ///
    /// @param lockup The Sablier V2 contract.
    function cancel(ISablierV2Lockup lockup, uint256 streamId) external;

    /// @notice Target function to cancel multiple streams.
    ///
    /// 1. Queries the proxy balances of each asset before the streams are canceled.
    /// 2. Performs an external call on {SablierV2Lockup.cancelMultiple}.
    /// 3. Transfers the return amounts sum to proxy owner, if greater than zero.
    ///
    /// @dev Notes:
    /// - The function assumes that the assets of the `params.streamIds` are the same as those in `assets` array.
    /// If any asset is missing, the returned amount will be left in the proxy contract.
    /// - See {ISablierV2Lockup.cancelMultiple} for documentation.
    /// - `lockup` can be either {SablierV2LockupLinear} or {SablierV2LockupDynamic} contract.
    ///
    /// @param lockup The Sablier V2 contract.
    /// @param assets The contracts of the ERC-20 assets used for streaming.
    function cancelMultiple(ISablierV2Lockup lockup, IERC20[] calldata assets, uint256[] calldata streamIds) external;

    /// @notice Target function to renounce a stream.
    ///
    /// @dev Notes:
    /// - See {ISablierV2Lockup.renounce} for documentation.
    /// - `lockup` can be either {SablierV2LockupLinear} or {SablierV2LockupDynamic} contract.
    ///
    /// @param lockup The Sablier V2 contract.
    function renounce(ISablierV2Lockup lockup, uint256 streamId) external;

    /// @notice Target function to withdraw assets.
    ///
    /// @dev Notes:
    /// - See {ISablierV2Lockup.withdraw} for documentation.
    /// - `lockup` can be either {SablierV2LockupLinear} or {SablierV2LockupDynamic} contract.
    ///
    /// @param lockup The Sablier V2 contract.
    function withdraw(ISablierV2Lockup lockup, uint256 streamId, address to, uint128 amount) external;

    /// @notice Target function to withdraw the maximum withdrawable amount.
    ///
    /// @dev Notes:
    /// - See {ISablierV2Lockup.withdrawMax} for documentation.
    /// - `lockup` can be either {SablierV2LockupLinear} or {SablierV2LockupDynamic} contract.
    ///
    /// @param lockup The Sablier V2 contract.
    function withdrawMax(ISablierV2Lockup lockup, uint256 streamId, address to) external;

    /*//////////////////////////////////////////////////////////////////////////
                              SABLIER-V2-LOCKUP-LINEAR
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Cancels a stream and creates a new one with durations.
    ///
    /// @dev Notes:
    /// - See {ISablierV2Lockup.cancel} and {ISablierV2LockupLinear.createWithDurations} for documentation.
    /// - `lockup` can be either {SablierV2LockupLinear} or {SablierV2LockupDynamic} contract.
    /// - The `streamId` can point to a linear or dynamic stream.
    /// - Transfers assets from  `msg.sender` to the proxy using Permit2.
    ///
    /// @param lockup The Sablier V2 contract.
    /// @param linear The address of the [SablierV2LockupLinear} contract.
    /// @param permit2Params The struct that encapsulates the variables needed for Permit2.
    /// @return newStreamId The stream id of the newly created stream.
    function cancelAndCreateWithDurations(
        ISablierV2Lockup lockup,
        ISablierV2LockupLinear linear,
        uint256 streamId,
        LockupLinear.CreateWithDurations calldata params,
        Permit2Params calldata permit2Params
    )
        external
        returns (uint256 newStreamId);

    /// @notice Cancels a stream and creates a new one with range.
    ///
    /// @dev Notes:
    /// - See {ISablierV2Lockup.cancel} and {ISablierV2LockupLinear.createWithRange} for documentation.
    /// - `lockup` can be either {SablierV2LockupLinear} or {SablierV2LockupDynamic} contract.
    /// - The `streamId` can point to a linear or dynamic stream.
    /// - Transfers assets from  `msg.sender` to the proxy using Permit2.
    ///
    /// @param lockup The Sablier V2 contract.
    /// @param linear The address of the [SablierV2LockupLinear} contract.
    /// @param permit2Params The struct that encapsulates the variables needed for Permit2.
    /// @return newStreamId The stream id of the newly created stream.
    function cancelAndCreateWithRange(
        ISablierV2Lockup lockup,
        ISablierV2LockupLinear linear,
        uint256 streamId,
        LockupLinear.CreateWithRange calldata params,
        Permit2Params calldata permit2Params
    )
        external
        returns (uint256 newStreamId);

    /// @notice Target function to create a linear stream with durations.
    ///
    /// @dev Notes:
    /// - See {ISablierV2LockupLinear.createWithDurations} for documentation.
    /// - Transfers assets from  `msg.sender` to the proxy using Permit2.
    ///
    /// @param linear The address of the [SablierV2LockupLinear} contract.
    /// @param permit2Params The struct that encapsulates the variables needed for Permit2.
    function createWithDurations(
        ISablierV2LockupLinear linear,
        LockupLinear.CreateWithDurations calldata params,
        Permit2Params calldata permit2Params
    )
        external
        returns (uint256 streamId);

    /// @notice Target function to create a linear stream with range.
    ///
    /// @dev Notes:
    /// - See {ISablierV2LockupLinear.createWithRange} for documentation.
    /// - Transfers assets from  `msg.sender` to the proxy using Permit2.
    ///
    /// @param linear The address of the [SablierV2LockupLinear} contract.
    /// @param permit2Params The struct that encapsulates the variables needed for Permit2.
    function createWithRange(
        ISablierV2LockupLinear linear,
        LockupLinear.CreateWithRange calldata params,
        Permit2Params calldata permit2Params
    )
        external
        returns (uint256 streamId);

    /// @notice Creates multiple linear streams with durations funded by `msg.sender`.
    ///
    /// @dev We use an array of structs for the parameters to avoid the "Stack Too Deep" error.
    ///
    /// Notes:
    /// - Transfers assets from  `msg.sender` to the proxy using Permit2.
    ///
    /// Requirements:
    /// - `totalAmount` must not be zero.
    /// - `params` must be non-empty.
    /// - The params amounts summed up must be equal to the `totalAmount`.
    ///
    /// @param linear The address of the [SablierV2LockupLinear} contract.
    /// @param asset The contract of the ERC-20 asset used for streaming.
    /// @param totalAmount The amount of assets for all the streams, in units of the asset's decimals.
    /// @param params The array of structs that partially encapsulates the
    /// {SablierV2LockupLinear.createWithDurations} function parameters.
    /// @param permit2Params The struct that encapsulates the variables needed for Permit2.
    /// @return streamIds The ids of the newly created streams.
    function batchCreateWithDurations(
        ISablierV2LockupLinear linear,
        IERC20 asset,
        uint128 totalAmount,
        Batch.CreateWithDurations[] calldata params,
        Permit2Params calldata permit2Params
    )
        external
        returns (uint256[] memory streamIds);

    /// @notice Creates multiple linear streams with range funded by `msg.sender`.
    ///
    /// @dev We use an array of structs for the parameters to avoid the "Stack Too Deep" error.
    ///
    /// Notes:
    /// - Transfers assets from  `msg.sender` to the proxy using Permit2.
    ///
    /// Requirements:
    /// - `totalAmount` must not be zero.
    /// - `params` must be non-empty.
    /// - The params amounts summed up must be equal to the `totalAmount`.
    ///
    /// @param linear The address of the [SablierV2LockupLinear} contract.
    /// @param asset The contract of the ERC-20 asset used for streaming.
    /// @param totalAmount The amount of assets for all the streams, in units of the asset's decimals.
    /// @param params The array of structs that partially encapsulates the
    /// {SablierV2LockupLinear.createWithRange} function parameters.
    /// @param permit2Params The struct that encapsulates the variables needed for Permit2.
    /// @return streamIds The ids of the newly created streams.
    function batchCreateWithRange(
        ISablierV2LockupLinear linear,
        IERC20 asset,
        uint128 totalAmount,
        Batch.CreateWithRange[] calldata params,
        Permit2Params calldata permit2Params
    )
        external
        returns (uint256[] memory streamIds);

    /// @notice Wraps the native assets in ERC-20 form and creates a linear stream with durations.
    ///
    /// @dev Notes:
    /// - `params.totalAmount` will be overwritten with the `msg.value`.
    /// - See {ISablierV2LockupLinear.createWithDurations} for documentation.
    ///
    /// @param linear The address of the [SablierV2LockupLinear} contract.
    function wrapAndCreateWithDurations(
        ISablierV2LockupLinear linear,
        LockupLinear.CreateWithDurations memory params
    )
        external
        payable
        returns (uint256 streamId);

    /// @notice Wraps the native assets in ERC-20 form and creates a linear stream with range.
    ///
    /// @dev Notes:
    /// - `params.totalAmount` will be overwritten with the `msg.value`.
    /// - See {ISablierV2LockupLinear.createWithRange} for documentation.
    ///
    /// @param linear The address of the [SablierV2LockupLinear} contract.
    function wrapAndCreateWithRange(
        ISablierV2LockupLinear linear,
        LockupLinear.CreateWithRange memory params
    )
        external
        payable
        returns (uint256 streamId);

    /*//////////////////////////////////////////////////////////////////////////
                               SABLIER-V2-LOCKUP-PRO
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Cancels a stream and creates a new one with deltas.
    ///
    /// @dev Notes:
    /// - See {ISablierV2Lockup.cancel} and {ISablierV2LockupDynamic.createWithDeltas} for documentation.
    /// - `lockup` can be either {SablierV2LockupLinear} or {SablierV2LockupDynamic} contract.
    /// - The `streamId` can point to a linear or dynamic stream.
    /// - Transfers assets from  `msg.sender` to the proxy using Permit2.
    ///
    /// @param lockup The Sablier V2 contract.
    /// @param dynamic The address of the [SablierV2LockupDynamic} contract.
    /// @param permit2Params The struct that encapsulates the variables needed for Permit2.
    /// @return newStreamId The stream id of the newly created stream.
    function cancelAndCreateWithDeltas(
        ISablierV2Lockup lockup,
        ISablierV2LockupDynamic dynamic,
        uint256 streamId,
        LockupDynamic.CreateWithDeltas calldata params,
        Permit2Params calldata permit2Params
    )
        external
        returns (uint256 newStreamId);

    /// @notice Cancels a stream and creates a new one with milestones.
    ///
    /// @dev Notes:
    /// - See {ISablierV2Lockup.cancel} and {ISablierV2LockupDynamic.createWithMilestones} for documentation.
    /// - `lockup` can be either {SablierV2LockupLinear} or {SablierV2LockupDynamic} contract.
    /// - The `streamId` can point to a linear or dynamic stream.
    /// - Transfers assets from  `msg.sender` to the proxy using Permit2.
    ///
    /// @param lockup The Sablier V2 contract.
    /// @param dynamic The address of the [SablierV2LockupDynamic} contract.
    /// @param permit2Params The struct that encapsulates the variables needed for Permit2.
    /// @return newStreamId The stream id of the newly created stream.
    function cancelAndCreateWithMilestones(
        ISablierV2Lockup lockup,
        ISablierV2LockupDynamic dynamic,
        uint256 streamId,
        LockupDynamic.CreateWithMilestones calldata params,
        Permit2Params calldata permit2Params
    )
        external
        returns (uint256 newStreamId);

    /// @notice Target function to create a dynamic stream with deltas.
    ///
    /// @dev Notes:
    /// - See {ISablierV2LockupDynamic.createWithDeltas} for documentation.
    /// - Transfers assets from  `msg.sender` to the proxy using Permit2.
    ///
    /// @param dynamic The address of the [SablierV2LockupDynamic} contract.
    /// @param permit2Params The struct that encapsulates the variables needed for Permit2.
    function createWithDeltas(
        ISablierV2LockupDynamic dynamic,
        LockupDynamic.CreateWithDeltas calldata params,
        Permit2Params calldata permit2Params
    )
        external
        returns (uint256 streamId);

    /// @notice Target function to create a dynamic stream with milestones.
    ///
    /// @dev Notes:
    /// - See {ISablierV2LockupDynamic.createWithMilestones} for documentation.
    /// - Transfers assets from  `msg.sender` to the proxy using Permit2.
    ///
    /// @param dynamic The address of the [SablierV2LockupDynamic} contract.
    /// @param permit2Params The struct that encapsulates the variables needed for Permit2.
    function createWithMilestones(
        ISablierV2LockupDynamic dynamic,
        LockupDynamic.CreateWithMilestones calldata params,
        Permit2Params calldata permit2Params
    )
        external
        returns (uint256 streamId);

    /// @notice Creates multiple pro streams with deltas funded by `msg.sender`.
    ///
    /// @dev We use an array of structs for the parameters to avoid the "Stack Too Deep" error.
    ///
    /// Notes:
    /// - Transfers assets from  `msg.sender` to the proxy using Permit2.
    ///
    /// Requirements:
    /// - `totalAmount` must not be zero.
    /// - `params` must be non-empty.
    /// - The params amounts summed up must be equal to the `totalAmount`.
    ///
    /// @param dynamic The address of the [SablierV2LockupDynamic} contract.
    /// @param asset The contract of the ERC-20 asset used for streaming.
    /// @param totalAmount The amount of assets for all the streams, in units of the asset's decimals.
    /// @param params The array of structs that partially encapsulates the
    /// {SablierV2LockupDynamic.createWithDelta} function parameters.
    /// @param permit2Params The struct that encapsulates the variables needed for Permit2.
    /// @return streamIds The ids of the newly created streams.
    function batchCreateWithDeltas(
        ISablierV2LockupDynamic dynamic,
        IERC20 asset,
        uint128 totalAmount,
        Batch.CreateWithDeltas[] calldata params,
        Permit2Params calldata permit2Params
    )
        external
        returns (uint256[] memory streamIds);

    /// @notice Creates multiple pro streams with milestones funded by `msg.sender`.
    ///
    /// @dev We use an array of structs for the parameters to avoid the "Stack Too Deep" error.
    ///
    /// Notes:
    /// - Transfers assets from  `msg.sender` to the proxy using Permit2.
    ///
    /// Requirements:
    /// - `totalAmount` must not be zero.
    /// - `params` must be non-empty.
    /// - The params amounts summed up must be equal to the `totalAmount`.
    ///
    /// @param dynamic The address of the [SablierV2LockupDynamic} contract.
    /// @param asset The contract of the ERC-20 asset used for streaming.
    /// @param totalAmount The amount of assets for all the streams, in units of the asset's decimals.
    /// @param params The array of structs that partially encapsulates the
    /// {SablierV2LockupDynamic.createWithMilestones} function parameters.
    /// @param permit2Params The struct that encapsulates the variables needed for Permit2.
    /// @return streamIds The ids of the newly created streams.
    function batchCreateWithMilestones(
        ISablierV2LockupDynamic dynamic,
        IERC20 asset,
        uint128 totalAmount,
        Batch.CreateWithMilestones[] calldata params,
        Permit2Params calldata permit2Params
    )
        external
        returns (uint256[] memory streamIds);

    /// @notice Wraps the native assets in ERC-20 form and creates a dynamic stream with deltas.
    ///
    /// @dev Notes:
    /// - `params.totalAmount` will be overwritten with the `msg.value`.
    /// - See {ISablierV2LockupDynamic.createWithDeltas} for documentation.
    ///
    /// @param dynamic The address of the [SablierV2LockupDynamic} contract.
    /// @param params Struct encapsulating the function parameters, which are documented in {DataTypes}.
    function wrapAndCreateWithDeltas(
        ISablierV2LockupDynamic dynamic,
        LockupDynamic.CreateWithDeltas memory params
    )
        external
        payable
        returns (uint256 streamId);

    /// @notice Wraps the native assets in ERC-20 form and creates a dynamic stream with milestones.
    ///
    /// @dev Notes:
    /// - `params.totalAmount` will be overwritten with the `msg.value`.
    /// - See {ISablierV2LockupDynamic.createWithMilestones} for documentation.
    ///
    /// @param dynamic The address of the [SablierV2LockupDynamic} contract.
    /// @param params Struct encapsulating the function parameters, which are documented in {DataTypes}.
    function wrapAndCreateWithMilestones(
        ISablierV2LockupDynamic dynamic,
        LockupDynamic.CreateWithMilestones memory params
    )
        external
        payable
        returns (uint256 streamId);
}
