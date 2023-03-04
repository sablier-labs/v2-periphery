// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { ISablierV2Lockup } from "@sablier/v2-core/interfaces/ISablierV2Lockup.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";
import { ISablierV2LockupPro } from "@sablier/v2-core/interfaces/ISablierV2LockupPro.sol";
import { LockupLinear, LockupPro } from "@sablier/v2-core/types/DataTypes.sol";

import { IWETH9 } from "./IWETH9.sol";
import { CreateLinear, CreatePro } from "../types/DataTypes.sol";

interface ISablierV2ProxyTarget {
    /*//////////////////////////////////////////////////////////////////////////
                                 SABLIER-V2-LOCKUP
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Target function to cancel a stream.
    ///
    /// Notes:
    /// - See {ISablierV2Lockup-cancel} for documentation.
    /// - The `lockup` address can be either {SablierV2LockupLinear} or {SablierV2LockupPro} address.
    ///
    /// @param lockup The Sablier V2 contract.
    function cancel(ISablierV2Lockup lockup, uint256 streamId) external;

    /// @notice Target function to cancel multiple streams.
    ///
    /// Notes:
    /// - See {ISablierV2Lockup-cancelMultiple} for documentation.
    /// - The `lockup` address can be either {SablierV2LockupLinear} or {SablierV2LockupPro} address.
    ///
    /// Requirements:
    /// - All streams must have the same asset.
    ///
    /// @param lockup The Sablier V2 contract.
    function cancelMultiple(ISablierV2Lockup lockup, IERC20 asset, uint256[] calldata streamIds) external;

    /// @notice Target function to renounce a stream.
    ///
    /// Notes:
    /// - See {ISablierV2Lockup-renounce} for documentation.
    /// - The `lockup` address can be either {SablierV2LockupLinear} or {SablierV2LockupPro} address.
    ///
    /// @param lockup The Sablier V2 contract.
    function renounce(ISablierV2Lockup lockup, uint256 streamId) external;

    /// @notice Target function to withdraw assets.
    ///
    /// Notes:
    /// - See {ISablierV2Lockup-withdraw} for documentation.
    /// - The `lockup` address can be either {SablierV2LockupLinear} or {SablierV2LockupPro} address.
    ///
    /// @param lockup The Sablier V2 contract.
    function withdraw(ISablierV2Lockup lockup, uint256 streamId, address to, uint128 amount) external;

    /// @notice Target function to withdraw the maximum withdrawable amount.
    ///
    /// Notes:
    /// - See {ISablierV2Lockup-withdrawMax} for documentation.
    /// - The `lockup` address can be either {SablierV2LockupLinear} or {SablierV2LockupPro} address.
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
    /// - The `lockup` address can be either {SablierV2LockupLinear} or {SablierV2LockupPro} address.
    ///
    /// @param lockup The Sablier V2 contract.
    /// @param linear The Sablier V2 linear contract.
    function cancelAndCreateWithDurations(
        ISablierV2Lockup lockup,
        ISablierV2LockupLinear linear,
        uint256 streamId,
        LockupLinear.CreateWithDurations calldata params
    ) external returns (uint256 newStreamId);

    /// @notice Cancels a stream and creates a new one with range.
    ///
    /// Notes:
    /// - See {ISablierV2Lockup-cancel} and {ISablierV2LockupLinear-createWithRange} for documentation.
    /// - The `lockup` address can be either {SablierV2LockupLinear} or {SablierV2LockupPro} address.
    ///
    /// @param lockup The Sablier V2 contract.
    /// @param linear The Sablier V2 linear contract.
    function cancelAndCreateWithRange(
        ISablierV2Lockup lockup,
        ISablierV2LockupLinear linear,
        uint256 streamId,
        LockupLinear.CreateWithRange calldata params
    ) external returns (uint256 newStreamId);

    /// @notice Target function to create a linear stream with durations.
    ///
    /// Notes
    /// - See {ISablierV2LockupLinear-createWithDurations} for documentation.
    ///
    /// @param linear The Sablier V2 linear contract.
    function createWithDurations(
        ISablierV2LockupLinear linear,
        LockupLinear.CreateWithDurations calldata params
    ) external returns (uint256 streamId);

    /// @notice Target function to create a linear stream with range.
    ///
    /// Notes
    /// - See {ISablierV2LockupLinear-createWithRange} for documentation.
    ///
    /// @param linear The Sablier V2 linear contract.
    function createWithRange(
        ISablierV2LockupLinear linear,
        LockupLinear.CreateWithRange calldata params
    ) external returns (uint256 streamId);

    /// @notice Creates multiple linear streams with durations funded by `msg.sender`.
    ///
    /// @dev We use an array of structs for the parameters to avoid the "Stack Too Deep" error.
    ///
    /// Requirements:
    /// - `totalAmount` must not be zero.
    /// - `params` must be non-empty.
    /// - The params amounts summed up must be equal to the `totalAmount`.
    ///
    /// @param linear The address of the {SablierV2LockupLinear} core contract.
    /// @param params The array of structs that partially encapsulates the
    /// {SablierV2LockupLinear-createWithDurations} function parameters.
    /// @param asset The contract address of the ERC-20 asset used for streaming.
    /// @param totalAmount The amount of assets for all the streams, in units of the asset's decimals.
    /// @return streamIds The ids of the newly created streams.
    function createWithDurationsMultiple(
        ISablierV2LockupLinear linear,
        CreateLinear.DurationsParams[] calldata params,
        IERC20 asset,
        uint128 totalAmount
    ) external returns (uint256[] memory streamIds);

    /// @notice Creates multiple linear streams with range funded by `msg.sender`.
    ///
    /// @dev We use an array of structs for the parameters to avoid the "Stack Too Deep" error.
    ///
    /// Requirements:
    /// - `totalAmount` must not be zero.
    /// - `params` must be non-empty.
    /// - The params amounts summed up must be equal to the `totalAmount`.
    ///
    /// @param linear The address of the {SablierV2LockupLinear} core contract.
    /// @param params The array of structs that partially encapsulates the
    /// {SablierV2LockupLinear-createWithRange} function parameters.
    /// @param asset The contract address of the ERC-20 asset used for streaming.
    /// @param totalAmount The amount of assets for all the streams, in units of the asset's decimals.
    /// @return streamIds The ids of the newly created streams.
    function createWithRangeMultiple(
        ISablierV2LockupLinear linear,
        CreateLinear.RangeParams[] calldata params,
        IERC20 asset,
        uint128 totalAmount
    ) external returns (uint256[] memory streamIds);

    /// @notice Wraps ETH into WETH9 and creates a linear stream with durations.
    ///
    /// Notes:
    /// - See {ISablierV2LockupLinear-createWithDurations} for documentation.
    ///
    /// Requirements:
    /// - `params.asset` must be the WETH9 contract address.
    /// - `msg.value` must be equal to `params.totalAmount`.
    ///
    /// @param weth9 The WETH9 contract.
    /// @param linear The Sablier V2 linear contract.
    function wrapEtherAndCreateWithDurations(
        IWETH9 weth9,
        ISablierV2LockupLinear linear,
        LockupLinear.CreateWithDurations calldata params
    ) external payable returns (uint256 streamId);

    /// @notice Wraps ETH into WETH9 and creates a linear stream with range.
    ///
    /// Notes:
    /// - See {ISablierV2LockupLinear-createWithRange} for documentation.
    ///
    /// Requirements:
    /// - `params.asset` must be the WETH9 contract address.
    /// - `msg.value` must be equal to `params.totalAmount`.
    ///
    /// @param weth9 The WETH9 contract.
    /// @param linear The Sablier V2 linear contract.
    function wrapEtherAndCreateWithRange(
        IWETH9 weth9,
        ISablierV2LockupLinear linear,
        LockupLinear.CreateWithRange calldata params
    ) external payable returns (uint256 streamId);

    /*//////////////////////////////////////////////////////////////////////////
                               SABLIER-V2-LOCKUP-PRO
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Cancels a stream and creates a new one with deltas.
    ///
    /// Notes:
    /// - See {ISablierV2Lockup-cancel} and {ISablierV2LockupPro-createWithDeltas} for documentation.
    /// - The `lockup` address can be either {SablierV2LockupLinear} or {SablierV2LockupPro} address.
    ///
    /// @param lockup The Sablier V2 contract.
    function cancelAndCreateWithDeltas(
        ISablierV2Lockup lockup,
        ISablierV2LockupPro pro,
        uint256 streamId,
        LockupPro.CreateWithDeltas calldata params
    ) external returns (uint256 newStreamId);

    /// @notice Cancels a stream and creates a new one with milestones.
    ///
    /// Notes:
    /// - See {ISablierV2Lockup-cancel} and {ISablierV2LockupPro-createWithMilestones} for documentation.
    /// - The `lockup` address can be either {SablierV2LockupLinear} or {SablierV2LockupPro} address.
    ///
    /// @param lockup The Sablier V2 contract.
    function cancelAndCreateWithMilestones(
        ISablierV2Lockup lockup,
        ISablierV2LockupPro pro,
        uint256 streamId,
        LockupPro.CreateWithMilestones calldata params
    ) external returns (uint256 newStreamId);

    /// @notice Target function to create a pro stream with deltas.
    ///
    /// Notes:
    /// - See {ISablierV2LockupPro-createWithDeltas} for documentation.
    ///
    /// @param pro The Sablier V2 pro contract.
    function createWithDelta(
        ISablierV2LockupPro pro,
        LockupPro.CreateWithDeltas calldata params
    ) external returns (uint256 streamId);

    /// @notice Target function to create a pro stream with milestones.
    ///
    /// Notes:
    /// - See {ISablierV2LockupPro-createWithMilestones} for documentation.
    ///
    /// @param pro The Sablier V2 pro contract.
    function createWithMilestones(
        ISablierV2LockupPro pro,
        LockupPro.CreateWithMilestones calldata params
    ) external returns (uint256 streamId);

    /// @notice Creates multiple pro streams with deltas funded by `msg.sender`.
    ///
    /// @dev We use an array of structs for the parameters to avoid the "Stack Too Deep" error.
    ///
    /// Requirements:
    /// - `totalAmount` must not be zero.
    /// - `params` must be non-empty.
    /// - The params amounts summed up must be equal to the `totalAmount`.
    ///
    /// @param pro The address of the {SablierV2LockupPro} core contract.
    /// @param params The array of structs that partially encapsulates the
    /// {SablierV2LockupPro-createWithDelta} function parameters.
    /// @param asset The contract address of the ERC-20 asset used for streaming.
    /// @param totalAmount The amount of assets for all the streams, in units of the asset's decimals.
    /// @return streamIds The ids of the newly created streams.
    function createWithDeltasMultiple(
        ISablierV2LockupPro pro,
        CreatePro.DeltasParams[] calldata params,
        IERC20 asset,
        uint128 totalAmount
    ) external returns (uint256[] memory streamIds);

    /// @notice Creates multiple pro streams with milestones funded by `msg.sender`.
    ///
    /// @dev We use an array of structs for the parameters to avoid the "Stack Too Deep" error.
    ///
    /// Requirements:
    /// - `totalAmount` must not be zero.
    /// - `params` must be non-empty.
    /// - The params amounts summed up must be equal to the `totalAmount`.
    ///
    /// @param pro The address of the {SablierV2LockupPro} core contract.
    /// @param params The array of structs that partially encapsulates the
    /// {SablierV2LockupPro-createWithMilestones} function parameters.
    /// @param asset The contract address of the ERC-20 asset used for streaming.
    /// @param totalAmount The amount of assets for all the streams, in units of the asset's decimals.
    /// @return streamIds The ids of the newly created streams.
    function createWithMilestonesMultiple(
        ISablierV2LockupPro pro,
        CreatePro.MilestonesParams[] calldata params,
        IERC20 asset,
        uint128 totalAmount
    ) external returns (uint256[] memory streamIds);

    /// @notice Wraps ETH into WETH9 and creates a pro stream with deltas.
    ///
    /// Notes:
    /// - See {ISablierV2LockupPro-createWithDeltas} for documentation.
    ///
    /// Requirements:
    /// - `params.asset` must be the WETH9 contract address.
    /// - `msg.value` must be equal to `params.totalAmount`.
    ///
    /// @param weth9 The WETH9 contract.
    /// @param pro The Sablier V2 pro contract.
    function wrapEtherAndCreateWithDeltas(
        IWETH9 weth9,
        ISablierV2LockupPro pro,
        LockupPro.CreateWithDeltas calldata params
    ) external payable returns (uint256 streamId);

    /// @notice Wraps ETH into WETH9 and creates a pro stream with milestones.
    ///
    /// Notes:
    /// - See {ISablierV2LockupPro-createWithMilestones} for documentation.
    ///
    /// Requirements:
    /// - `params.asset` must be the WETH9 contract address.
    /// - `msg.value` must be equal to `params.totalAmount`.
    ///
    /// @param weth9 The WETH9 contract.
    /// @param pro The Sablier V2 pro contract.
    function wrapEtherAndCreateWithMilestones(
        IWETH9 weth9,
        ISablierV2LockupPro pro,
        LockupPro.CreateWithMilestones calldata params
    ) external payable returns (uint256 streamId);
}
