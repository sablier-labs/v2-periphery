// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.13;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";
import { ISablierV2LockupPro } from "@sablier/v2-core/interfaces/ISablierV2LockupPro.sol";

import { Errors } from "./Errors.sol";
import { CreateLinear, CreatePro } from "../types/DataTypes.sol";

library Helpers {
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Helper function that transfers `value` funds from `msg.sender` to `address(this)`
    /// and approves `value` to `spender`.
    function transferAndApprove(address spender, IERC20 asset, uint256 value) external {
        asset.safeTransferFrom({ from: msg.sender, to: address(this), value: value });
        asset.safeApprove(spender, value);
    }

    /// @dev Helper function that performs an external call on {SablierV2LockupPro-createWithDeltas}.
    function callCreateWithDeltas(
        CreatePro.DeltasParams calldata params,
        IERC20 asset,
        ISablierV2LockupPro pro
    ) external returns (uint256 streamId) {
        streamId = pro.createWithDeltas(
            params.sender,
            params.recipient,
            params.amount,
            params.segments,
            asset,
            params.cancelable,
            params.deltas,
            params.broker
        );
    }

    /// @dev Helper function that performs an external call on {SablierV2LockupLinear-createWithDurations}.
    function callCreateWithDurations(
        CreateLinear.DurationsParams calldata params,
        IERC20 asset,
        ISablierV2LockupLinear linear
    ) external returns (uint256 streamId) {
        streamId = linear.createWithDurations(
            params.sender,
            params.recipient,
            params.amount,
            asset,
            params.cancelable,
            params.durations,
            params.broker
        );
    }

    /// @dev Helper function that performs an external call on {SablierV2LockupPro-createWithMilestones}.
    function callCreateWithMilestones(
        CreatePro.MilestonesParams calldata params,
        IERC20 asset,
        ISablierV2LockupPro pro
    ) external returns (uint256 streamId) {
        streamId = pro.createWithMilestones(
            params.sender,
            params.recipient,
            params.amount,
            params.segments,
            asset,
            params.cancelable,
            params.startTime,
            params.broker
        );
    }

    /// @dev Helper function that performs an external call on {SablierV2LockupLinear-createWithRange}.
    function callCreateWithRange(
        CreateLinear.RangeParams calldata params,
        IERC20 asset,
        ISablierV2LockupLinear linear
    ) external returns (uint256 streamId) {
        streamId = linear.createWithRange(
            params.sender,
            params.recipient,
            params.amount,
            asset,
            params.cancelable,
            params.range,
            params.broker
        );
    }

    /*//////////////////////////////////////////////////////////////////////////
                            INTERNAL CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Checks the arguments of the create multiple functions.
    function checkCreateMultipleParams(uint256 paramsCount, uint128 totalAmount, uint128 amountsSum) internal pure {
        // Checks: the total amount is not zero.
        if (totalAmount == 0) {
            revert Errors.BatchStream_TotalAmountZero();
        }

        // Checks: the parameters count is not zero.
        if (paramsCount == 0) {
            revert Errors.BatchStream_ParamsCountZero();
        }

        /// Checks: the total amount is equal to the parameters amounts summed up.
        if (amountsSum != totalAmount) {
            revert Errors.BatchStream_TotalAmountNotEqualToAmountsSum(totalAmount, amountsSum);
        }
    }
}
