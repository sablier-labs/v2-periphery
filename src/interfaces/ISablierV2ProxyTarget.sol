// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { ISablierV2Lockup } from "@sablier/v2-core/interfaces/ISablierV2Lockup.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";
import { ISablierV2LockupPro } from "@sablier/v2-core/interfaces/ISablierV2LockupPro.sol";
import { LockupLinear, LockupPro } from "@sablier/v2-core/types/DataTypes.sol";

import { IWETH9 } from "./IWETH9.sol";
import { Batch, Permit2Params } from "../types/DataTypes.sol";

/// @title ISablierV2ProxyTarget
/// @notice Target logic for the proxy contract.
interface ISablierV2ProxyTarget {
    /*//////////////////////////////////////////////////////////////////////////
                                 SABLIER-V2-LOCKUP
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Target function to cancel a stream on each `lockup` contract.
    ///
    /// Notes:
    /// - See {ISablierV2Lockup-cancel} for documentation.
    /// - `params.lockup` should include {SablierV2LockupLinear} and {SablierV2LockupPro} contracts.
    ///
    /// @param params Struct that encapsulates the lockup contract and the stream id.
    function batchCancel(Batch.Cancel[] calldata params) external;

    /// @notice Target function to cancel multiple streams on each `lockup` contract.
    ///
    /// Notes:
    /// - The function assumes that the assets which are used for streaming in the `params.streamIds` are the same
    /// as those in `assets` array. If any asset is missing, the returned amount will be left in the proxy contract.
    /// - See {ISablierV2Lockup-cancelMultiple} for documentation.
    /// - `params.lockup` should include {SablierV2LockupLinear} and {SablierV2LockupPro} contracts.
    ///
    /// @param params Struct that encapsulates the lockup contract and the stream ids.
    /// @param assets The contracts of the ERC-20 assets used for streaming.
    function batchCancelMultiple(Batch.CancelMultiple[] calldata params, IERC20[] calldata assets) external;

    /// @notice Target function to cancel a stream.
    ///
    /// Notes:
    /// - See {ISablierV2Lockup-cancel} for documentation.
    /// - `lockup` can be either {SablierV2LockupLinear} or {SablierV2LockupPro} contract.
    ///
    /// @param lockup The Sablier V2 contract.
    function cancel(ISablierV2Lockup lockup, uint256 streamId) external;

    /// @notice Target function to cancel multiple streams.
    ///
    /// Notes:
    /// - The function assumes that the assets which are used for streaming in the `streamIds` are the same as those
    /// in `assets` array. If any asset is missing, the returned amount will be left in the proxy contract.
    /// - See {ISablierV2Lockup-cancelMultiple} for documentation.
    /// - `lockup` can be either {SablierV2LockupLinear} or {SablierV2LockupPro} contract.
    ///
    /// @param lockup The Sablier V2 contract.
    /// @param assets The contracts of the ERC-20 assets used for streaming.
    function cancelMultiple(ISablierV2Lockup lockup, IERC20[] calldata assets, uint256[] calldata streamIds) external;

    /// @notice Target function to renounce a stream.
    ///
    /// Notes:
    /// - See {ISablierV2Lockup-renounce} for documentation.
    /// - `lockup` can be either {SablierV2LockupLinear} or {SablierV2LockupPro} contract.
    ///
    /// @param lockup The Sablier V2 contract.
    function renounce(ISablierV2Lockup lockup, uint256 streamId) external;

    /// @notice Target function to withdraw assets.
    ///
    /// Notes:
    /// - See {ISablierV2Lockup-withdraw} for documentation.
    /// - `lockup` can be either {SablierV2LockupLinear} or {SablierV2LockupPro} contract.
    ///
    /// @param lockup The Sablier V2 contract.
    function withdraw(ISablierV2Lockup lockup, uint256 streamId, address to, uint128 amount) external;

    /// @notice Target function to withdraw the maximum withdrawable amount.
    ///
    /// Notes:
    /// - See {ISablierV2Lockup-withdrawMax} for documentation.
    /// - `lockup` can be either {SablierV2LockupLinear} or {SablierV2LockupPro} contract.
    ///
    /// @param lockup The Sablier V2 contract.
    function withdrawMax(ISablierV2Lockup lockup, uint256 streamId, address to) external;

    /*//////////////////////////////////////////////////////////////////////////
                              SABLIER-V2-LOCKUP-LINEAR
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Cancels a stream and creates a new one with durations.
    ///
    /// Notes:
    /// - See {ISablierV2Lockup-cancel} and {ISablierV2LockupLinear-createWithDurations} for documentation.
    /// - `lockup` can be either {SablierV2LockupLinear} or {SablierV2LockupPro} contract.
    /// - The `streamId` can point to a linear or pro stream.
    /// - Transfers assets from  `msg.sender` to proxy via Permit2.
    ///
    /// @param lockup The Sablier V2 contract.
    /// @param linear The Sablier V2 linear contract.
    /// @param permit2Params The struct that encapsulates the variables needed for Permit2.
    /// @return newStreamId The stream id of the newly created stream.
    function cancelAndCreateWithDurations(
        ISablierV2Lockup lockup,
        ISablierV2LockupLinear linear,
        uint256 streamId,
        LockupLinear.CreateWithDurations calldata params,
        Permit2Params calldata permit2Params
    ) external returns (uint256 newStreamId);

    /// @notice Cancels a stream and creates a new one with range.
    ///
    /// Notes:
    /// - See {ISablierV2Lockup-cancel} and {ISablierV2LockupLinear-createWithRange} for documentation.
    /// - `lockup` can be either {SablierV2LockupLinear} or {SablierV2LockupPro} contract.
    /// - The `streamId` can point to a linear or pro stream.
    /// - Transfers assets from  `msg.sender` to proxy via Permit2.
    ///
    /// @param lockup The Sablier V2 contract.
    /// @param linear The Sablier V2 linear contract.
    /// @param permit2Params The struct that encapsulates the variables needed for Permit2.
    /// @return newStreamId The stream id of the newly created stream.
    function cancelAndCreateWithRange(
        ISablierV2Lockup lockup,
        ISablierV2LockupLinear linear,
        uint256 streamId,
        LockupLinear.CreateWithRange calldata params,
        Permit2Params calldata permit2Params
    ) external returns (uint256 newStreamId);

    /// @notice Target function to create a linear stream with durations.
    ///
    /// Notes:
    /// - See {ISablierV2LockupLinear-createWithDurations} for documentation.
    /// - Transfers assets from  `msg.sender` to proxy via Permit2.
    ///
    /// @param linear The Sablier V2 linear contract.
    /// @param permit2Params The struct that encapsulates the variables needed for Permit2.
    function createWithDurations(
        ISablierV2LockupLinear linear,
        LockupLinear.CreateWithDurations calldata params,
        Permit2Params calldata permit2Params
    ) external returns (uint256 streamId);

    /// @notice Target function to create a linear stream with range.
    ///
    /// Notes:
    /// - See {ISablierV2LockupLinear-createWithRange} for documentation.
    /// - Transfers assets from  `msg.sender` to proxy via Permit2.
    ///
    /// @param linear The Sablier V2 linear contract.
    /// @param permit2Params The struct that encapsulates the variables needed for Permit2.
    function createWithRange(
        ISablierV2LockupLinear linear,
        LockupLinear.CreateWithRange calldata params,
        Permit2Params calldata permit2Params
    ) external returns (uint256 streamId);

    /// @notice Creates multiple linear streams with durations funded by `msg.sender`.
    ///
    /// @dev We use an array of structs for the parameters to avoid the "Stack Too Deep" error.
    ///
    /// Notes:
    /// - Transfers assets from  `msg.sender` to proxy via Permit2.
    ///
    /// Requirements:
    /// - `totalAmount` must not be zero.
    /// - `params` must be non-empty.
    /// - The params amounts summed up must be equal to the `totalAmount`.
    ///
    /// @param linear The Sablier V2 linear contract.
    /// @param asset The contract of the ERC-20 asset used for streaming.
    /// @param totalAmount The amount of assets for all the streams, in units of the asset's decimals.
    /// @param params The array of structs that partially encapsulates the
    /// {SablierV2LockupLinear-createWithDurations} function parameters.
    /// @param permit2Params The struct that encapsulates the variables needed for Permit2.
    /// @return streamIds The ids of the newly created streams.
    function createWithDurationsMultiple(
        ISablierV2LockupLinear linear,
        IERC20 asset,
        uint128 totalAmount,
        Batch.CreateWithDurations[] calldata params,
        Permit2Params calldata permit2Params
    ) external returns (uint256[] memory streamIds);

    /// @notice Creates multiple linear streams with range funded by `msg.sender`.
    ///
    /// @dev We use an array of structs for the parameters to avoid the "Stack Too Deep" error.
    ///
    /// Notes:
    /// - Transfers assets from  `msg.sender` to proxy via Permit2.
    ///
    /// Requirements:
    /// - `totalAmount` must not be zero.
    /// - `params` must be non-empty.
    /// - The params amounts summed up must be equal to the `totalAmount`.
    ///
    /// @param linear The Sablier V2 linear contract.
    /// @param asset The contract of the ERC-20 asset used for streaming.
    /// @param totalAmount The amount of assets for all the streams, in units of the asset's decimals.
    /// @param params The array of structs that partially encapsulates the
    /// {SablierV2LockupLinear-createWithRange} function parameters.
    /// @param permit2Params The struct that encapsulates the variables needed for Permit2.
    /// @return streamIds The ids of the newly created streams.
    function createWithRangeMultiple(
        ISablierV2LockupLinear linear,
        IERC20 asset,
        uint128 totalAmount,
        Batch.CreateWithRange[] calldata params,
        Permit2Params calldata permit2Params
    ) external returns (uint256[] memory streamIds);

    /// @notice Wraps ETH into WETH9 and creates a linear stream with durations.
    ///
    /// Notes:
    /// - params.asset will be overwritten with the WETH9 contract.
    /// - params.totalAmount will be overwritten with the `msg.value`.
    /// - See {ISablierV2LockupLinear-createWithDurations} for documentation.
    /// - Transfers assets from  `msg.sender` to proxy via Permit2.
    ///
    /// @param linear The Sablier V2 linear contract.
    /// @param weth9 The WETH9 contract.
    function wrapEtherAndCreateWithDurations(
        ISablierV2LockupLinear linear,
        IWETH9 weth9,
        LockupLinear.CreateWithDurations memory params
    ) external payable returns (uint256 streamId);

    /// @notice Wraps ETH into WETH9 and creates a linear stream with range.
    ///
    /// Notes:
    /// - params.asset will be overwritten with the WETH9 contract.
    /// - params.totalAmount will be overwritten with the `msg.value`.
    /// - See {ISablierV2LockupLinear-createWithRange} for documentation.
    /// - Transfers assets from  `msg.sender` to proxy via Permit2.
    ///
    /// @param linear The Sablier V2 linear contract.
    /// @param weth9 The WETH9 contract.
    function wrapEtherAndCreateWithRange(
        ISablierV2LockupLinear linear,
        IWETH9 weth9,
        LockupLinear.CreateWithRange memory params
    ) external payable returns (uint256 streamId);

    /*//////////////////////////////////////////////////////////////////////////
                               SABLIER-V2-LOCKUP-PRO
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Cancels a stream and creates a new one with deltas.
    ///
    /// Notes:
    /// - See {ISablierV2Lockup-cancel} and {ISablierV2LockupPro-createWithDeltas} for documentation.
    /// - `lockup` can be either {SablierV2LockupLinear} or {SablierV2LockupPro} contract.
    /// - The `streamId` can point to a linear or pro stream.
    /// - Transfers assets from  `msg.sender` to proxy via Permit2.
    ///
    /// @param lockup The Sablier V2 contract.
    /// @param pro The Sablier V2 pro contract.
    /// @param permit2Params The struct that encapsulates the variables needed for Permit2.
    /// @return newStreamId The stream id of the newly created stream.
    function cancelAndCreateWithDeltas(
        ISablierV2Lockup lockup,
        ISablierV2LockupPro pro,
        uint256 streamId,
        LockupPro.CreateWithDeltas calldata params,
        Permit2Params calldata permit2Params
    ) external returns (uint256 newStreamId);

    /// @notice Cancels a stream and creates a new one with milestones.
    ///
    /// Notes:
    /// - See {ISablierV2Lockup-cancel} and {ISablierV2LockupPro-createWithMilestones} for documentation.
    /// - `lockup` can be either {SablierV2LockupLinear} or {SablierV2LockupPro} contract.
    /// - The `streamId` can point to a linear or pro stream.
    /// - Transfers assets from  `msg.sender` to proxy via Permit2.
    ///
    /// @param lockup The Sablier V2 contract.
    /// @param pro The Sablier V2 pro contract.
    /// @param permit2Params The struct that encapsulates the variables needed for Permit2.
    /// @return newStreamId The stream id of the newly created stream.
    function cancelAndCreateWithMilestones(
        ISablierV2Lockup lockup,
        ISablierV2LockupPro pro,
        uint256 streamId,
        LockupPro.CreateWithMilestones calldata params,
        Permit2Params calldata permit2Params
    ) external returns (uint256 newStreamId);

    /// @notice Target function to create a pro stream with deltas.
    ///
    /// Notes:
    /// - See {ISablierV2LockupPro-createWithDeltas} for documentation.
    /// - Transfers assets from  `msg.sender` to proxy via Permit2.
    ///
    /// @param pro The Sablier V2 pro contract.
    /// @param permit2Params The struct that encapsulates the variables needed for Permit2.
    function createWithDelta(
        ISablierV2LockupPro pro,
        LockupPro.CreateWithDeltas calldata params,
        Permit2Params calldata permit2Params
    ) external returns (uint256 streamId);

    /// @notice Target function to create a pro stream with milestones.
    ///
    /// Notes:
    /// - See {ISablierV2LockupPro-createWithMilestones} for documentation.
    /// - Transfers assets from  `msg.sender` to proxy via Permit2.
    ///
    /// @param pro The Sablier V2 pro contract.
    /// @param permit2Params The struct that encapsulates the variables needed for Permit2.
    function createWithMilestones(
        ISablierV2LockupPro pro,
        LockupPro.CreateWithMilestones calldata params,
        Permit2Params calldata permit2Params
    ) external returns (uint256 streamId);

    /// @notice Creates multiple pro streams with deltas funded by `msg.sender`.
    ///
    /// @dev We use an array of structs for the parameters to avoid the "Stack Too Deep" error.
    ///
    /// Notes:
    /// - Transfers assets from  `msg.sender` to proxy via Permit2.
    ///
    /// Requirements:
    /// - `totalAmount` must not be zero.
    /// - `params` must be non-empty.
    /// - The params amounts summed up must be equal to the `totalAmount`.
    ///
    /// @param pro The Sablier V2 pro contract.
    /// @param asset The contract of the ERC-20 asset used for streaming.
    /// @param totalAmount The amount of assets for all the streams, in units of the asset's decimals.
    /// @param params The array of structs that partially encapsulates the
    /// {SablierV2LockupPro-createWithDelta} function parameters.
    /// @param permit2Params The struct that encapsulates the variables needed for Permit2.
    /// @return streamIds The ids of the newly created streams.
    function createWithDeltasMultiple(
        ISablierV2LockupPro pro,
        IERC20 asset,
        uint128 totalAmount,
        Batch.CreateWithDeltas[] calldata params,
        Permit2Params calldata permit2Params
    ) external returns (uint256[] memory streamIds);

    /// @notice Creates multiple pro streams with milestones funded by `msg.sender`.
    ///
    /// @dev We use an array of structs for the parameters to avoid the "Stack Too Deep" error.
    ///
    /// Notes:
    /// - Transfers assets from  `msg.sender` to proxy via Permit2.
    ///
    /// Requirements:
    /// - `totalAmount` must not be zero.
    /// - `params` must be non-empty.
    /// - The params amounts summed up must be equal to the `totalAmount`.
    ///
    /// @param pro The Sablier V2 pro contract.
    /// @param asset The contract of the ERC-20 asset used for streaming.
    /// @param totalAmount The amount of assets for all the streams, in units of the asset's decimals.
    /// @param params The array of structs that partially encapsulates the
    /// {SablierV2LockupPro-createWithMilestones} function parameters.
    /// @param permit2Params The struct that encapsulates the variables needed for Permit2.
    /// @return streamIds The ids of the newly created streams.
    function createWithMilestonesMultiple(
        ISablierV2LockupPro pro,
        IERC20 asset,
        uint128 totalAmount,
        Batch.CreateWithMilestones[] calldata params,
        Permit2Params calldata permit2Params
    ) external returns (uint256[] memory streamIds);

    /// @notice Wraps ETH into WETH9 and creates a pro stream with deltas.
    ///
    /// Notes:
    /// - params.asset will be overwritten with the WETH9 contract.
    /// - params.totalAmount will be overwritten with the `msg.value`.
    /// - See {ISablierV2LockupPro-createWithDeltas} for documentation.
    /// - Transfers assets from  `msg.sender` to proxy via Permit2.
    ///
    /// @param pro The Sablier V2 pro contract.
    /// @param weth9 The WETH9 contract.
    function wrapEtherAndCreateWithDeltas(
        ISablierV2LockupPro pro,
        IWETH9 weth9,
        LockupPro.CreateWithDeltas memory params
    ) external payable returns (uint256 streamId);

    /// @notice Wraps ETH into WETH9 and creates a pro stream with milestones.
    ///
    /// Notes:
    /// - params.asset will be overwritten with the WETH9 contract.
    /// - params.totalAmount will be overwritten with the `msg.value`.
    /// - See {ISablierV2LockupPro-createWithMilestones} for documentation.
    /// - Transfers assets from  `msg.sender` to proxy via Permit2.
    ///
    /// @param pro The Sablier V2 pro contract.
    /// @param weth9 The WETH9 contract.
    function wrapEtherAndCreateWithMilestones(
        ISablierV2LockupPro pro,
        IWETH9 weth9,
        LockupPro.CreateWithMilestones memory params
    ) external payable returns (uint256 streamId);
}
