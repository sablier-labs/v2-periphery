// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.18;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";
import { ISablierV2LockupPro } from "@sablier/v2-core/interfaces/ISablierV2LockupPro.sol";

import { CreateLinear, CreatePro } from "../types/DataTypes.sol";

interface ISablierV2ProxyTarget {
    /*//////////////////////////////////////////////////////////////////////////
                              SABLIER-V2-LOCKUP-LINEAR
    //////////////////////////////////////////////////////////////////////////*/

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

    /*//////////////////////////////////////////////////////////////////////////
                               SABLIER-V2-LOCKUP-PRO
    //////////////////////////////////////////////////////////////////////////*/

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
}
