// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.13;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";
import { ISablierV2LockupPro } from "@sablier/v2-core/interfaces/ISablierV2LockupPro.sol";

import { CreateLinear, CreatePro } from "../types/DataTypes.sol";

interface IBatchStream {
    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice The address of the {SablierV2LockupLinear} core contract.
    function linear() external view returns (ISablierV2LockupLinear);

    /// @notice The address of the {SablierV2LockupPro} core contract.
    function pro() external view returns (ISablierV2LockupPro);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Creates multiple pro streams with deltas funded by `msg.sender`.
    ///
    /// @dev The function perform the {SablierV2LockupPro-createWithDeltas} external calls with a
    /// with a try/catch statement so that it will never fail.
    ///
    /// Notes: We use an array of structs for the parameters to avoid the "Stack Too Deep" error.
    ///
    /// Requirements:
    /// - `totalAmount` must not be zero.
    /// - `params` must be non-empty.
    /// - The params amounts summed up must be equal to the `totalAmount`.
    ///
    /// @param params The {SablierV2LockupPro-createWithDeltas} parameters packed in a struct.
    /// @param asset The contract address of the ERC-20 asset used for streaming.
    /// @param totalAmount The amount of assets for all the streams, in units of the asset's decimals.
    /// @return streamIds The ids of the newly created streams.
    function createWithDeltasMultiple(
        CreatePro.DeltasParams[] calldata params,
        IERC20 asset,
        uint128 totalAmount
    ) external returns (uint256[] memory streamIds);

    /// @notice Creates multiple linear streams with durations funded by `msg.sender`.
    ///
    /// @dev The function perform the {SablierV2LockupLinear-createWithDurations} external calls with a
    /// with a try/catch statement so that it will never fail.
    ///
    /// Notes: We use an array of structs for the parameters to avoid the "Stack Too Deep" error.
    ///
    /// Requirements:
    /// - `totalAmount` must not be zero.
    /// - `params` must be non-empty.
    /// - The params amounts summed up must be equal to the `totalAmount`.
    ///
    /// @param params The {SablierV2LockupLinear-createWithDurations} parameters packed in a struct.
    /// @param asset The contract address of the ERC-20 asset used for streaming.
    /// @param totalAmount The amount of assets for all the streams, in units of the asset's decimals.
    /// @return streamIds The ids of the newly created streams.
    function createWithDurationsMultiple(
        CreateLinear.DurationsParams[] calldata params,
        IERC20 asset,
        uint128 totalAmount
    ) external returns (uint256[] memory streamIds);

    /// @notice Creates multiple pro streams with milestones funded by `msg.sender`.
    ///
    /// @dev The function perform the {SablierV2LockupPro-createWithMilestones} external calls with a
    /// with a try/catch statement so that it will never fail.
    ///
    /// Notes: We use an array of structs for the parameters to avoid the "Stack Too Deep" error.
    ///
    /// Requirements:
    /// - `totalAmount` must not be zero.
    /// - `params` must be non-empty.
    /// - The params amounts summed up must be equal to the `totalAmount`.
    ///
    /// @param params The {SablierV2LockupPro-createWithMilestones} parameters packed in a struct.
    /// @param asset The contract address of the ERC-20 asset used for streaming.
    /// @param totalAmount The amount of assets for all the streams, in units of the asset's decimals.
    /// @return streamIds The ids of the newly created streams.
    function createWithMilestonesMultiple(
        CreatePro.MilestonesParams[] calldata params,
        IERC20 asset,
        uint128 totalAmount
    ) external returns (uint256[] memory streamIds);

    /// @notice Creates multiple linear streams with range funded by `msg.sender`.
    ///
    /// @dev The function perform the {SablierV2LockupLinear-createWithRange} external calls with a
    /// with a try/catch statement so that it will never fail.
    ///
    /// Notes: We use an array of structs for the parameters to avoid the "Stack Too Deep" error.
    ///
    /// Requirements:
    /// - `totalAmount` must not be zero.
    /// - `params` must be non-empty.
    /// - The params amounts summed up must be equal to the `totalAmount`.
    ///
    /// @param params The {SablierV2LockupLinear-createWithRange} parameters packed in a struct.
    /// @param asset The contract address of the ERC-20 asset used for streaming.
    /// @param totalAmount The amount of assets for all the streams, in units of the asset's decimals.
    /// @return streamIds The ids of the newly created streams.
    function createWithRangeMultiple(
        CreateLinear.RangeParams[] calldata params,
        IERC20 asset,
        uint128 totalAmount
    ) external returns (uint256[] memory streamIds);
}
