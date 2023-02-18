// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.18;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";
import { ISablierV2LockupPro } from "@sablier/v2-core/interfaces/ISablierV2LockupPro.sol";
import { LockupLinear, LockupPro } from "@sablier/v2-core/types/DataTypes.sol";

import { Errors } from "./Errors.sol";
import { IWETH9 } from "../interfaces/IWETH9.sol";
import { CreateLinear, CreatePro } from "../types/DataTypes.sol";

library Helpers {
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////////////////
                            INTERNAL CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Checks the arguments of the create multiple functions.
    function checkCreateMultipleParams(uint256 paramsCount, uint128 totalAmount, uint128 amountsSum) internal pure {
        // Checks: the total amount is not zero.
        if (totalAmount == 0) {
            revert Errors.SablierV2ProxyTarget_TotalAmountZero();
        }

        // Checks: the parameters count is not zero.
        if (paramsCount == 0) {
            revert Errors.SablierV2ProxyTarget_ParamsCountZero();
        }

        /// Checks: the total amount is equal to the parameters amounts summed up.
        if (amountsSum != totalAmount) {
            revert Errors.SablierV2ProxyTarget_TotalAmountNotEqualToAmountsSum(totalAmount, amountsSum);
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                          INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Checks the wrap function parameters and deposits the Ether into the WETH9 contract.
    function checkParamsAndDepositEther(IWETH9 weth9, IERC20 asset, uint256 amount) internal {
        // Checks: the asset is the actual WETH9 contract.
        if (asset != weth9) {
            revert Errors.SablierV2ProxyTarget_AssetNotWETH9(asset, weth9);
        }

        // Checks: the amount of WETH9 is the same as the amount of Ether sent.
        if (amount != msg.value) {
            revert Errors.SablierV2ProxyTarget_WrongEtherAmount(msg.value, amount);
        }

        // Interactions: deposit the Ether into the WETH9 contract.
        weth9.deposit{ value: amount }();
    }

    /// @dev Helper function that performs an external call on {SablierV2LockupPro-createWithDeltas}.
    function createWithDeltas(
        ISablierV2LockupPro pro,
        LockupPro.CreateWithDeltas calldata params
    ) internal returns (uint256 streamId) {
        transferAndApprove(address(pro), params.asset, params.totalAmount);
        streamId = pro.createWithDeltas(params);
    }

    /// @dev Helper function that performs an external call on {SablierV2LockupPro-createWithDeltas}.
    function createWithDeltas(
        ISablierV2LockupPro pro,
        CreatePro.DeltasParams calldata params,
        IERC20 asset
    ) internal returns (uint256 streamId) {
        streamId = pro.createWithDeltas(
            LockupPro.CreateWithDeltas({
                asset: asset,
                broker: params.broker,
                cancelable: params.cancelable,
                recipient: params.recipient,
                segments: params.segments,
                sender: params.sender,
                totalAmount: params.amount
            })
        );
    }

    /// @dev Helper function that performs an external call on {SablierV2LockupPro-createWithDurations}.
    function createWithDurations(
        ISablierV2LockupLinear linear,
        LockupLinear.CreateWithDurations calldata params
    ) internal returns (uint256 streamId) {
        transferAndApprove(address(linear), params.asset, params.totalAmount);
        streamId = linear.createWithDurations(params);
    }

    /// @dev Helper function that performs an external call on {SablierV2LockupLinear-createWithDurations}.
    function createWithDurations(
        ISablierV2LockupLinear linear,
        CreateLinear.DurationsParams calldata params,
        IERC20 asset
    ) internal returns (uint256 streamId) {
        streamId = linear.createWithDurations(
            LockupLinear.CreateWithDurations({
                asset: asset,
                broker: params.broker,
                cancelable: params.cancelable,
                durations: params.durations,
                recipient: params.recipient,
                sender: params.sender,
                totalAmount: params.amount
            })
        );
    }

    /// @dev Helper function that performs an external call on {SablierV2LockupPro-createWithMilestones}.
    function createWithMilestones(
        ISablierV2LockupPro pro,
        LockupPro.CreateWithMilestones calldata params
    ) internal returns (uint256 streamId) {
        transferAndApprove(address(pro), params.asset, params.totalAmount);
        streamId = pro.createWithMilestones(params);
    }

    /// @dev Helper function that performs an external call on {SablierV2LockupPro-createWithMilestones}.
    function createWithMilestones(
        ISablierV2LockupPro pro,
        CreatePro.MilestonesParams calldata params,
        IERC20 asset
    ) internal returns (uint256 streamId) {
        streamId = pro.createWithMilestones(
            LockupPro.CreateWithMilestones({
                asset: asset,
                broker: params.broker,
                cancelable: params.cancelable,
                recipient: params.recipient,
                segments: params.segments,
                sender: params.sender,
                startTime: params.startTime,
                totalAmount: params.amount
            })
        );
    }

    /// @dev Helper function that performs an external call on {SablierV2LockupLinear-createWithRange}.
    function createWithRange(
        ISablierV2LockupLinear linear,
        LockupLinear.CreateWithRange calldata params
    ) internal returns (uint256 streamId) {
        transferAndApprove(address(linear), params.asset, params.totalAmount);
        streamId = linear.createWithRange(params);
    }

    /// @dev Helper function that performs an external call on {SablierV2LockupLinear-createWithRange}.
    function createWithRange(
        ISablierV2LockupLinear linear,
        CreateLinear.RangeParams calldata params,
        IERC20 asset
    ) internal returns (uint256 streamId) {
        streamId = linear.createWithRange(
            LockupLinear.CreateWithRange({
                asset: asset,
                broker: params.broker,
                cancelable: params.cancelable,
                range: params.range,
                recipient: params.recipient,
                sender: params.sender,
                totalAmount: params.amount
            })
        );
    }

    /// @dev Helper function that transfers `value` funds from `msg.sender` to `address(this)`
    /// and approves `value` to `spender`.
    function transferAndApprove(address spender, IERC20 asset, uint256 value) internal {
        asset.safeTransferFrom({ from: msg.sender, to: address(this), value: value });
        asset.approve(spender, value);
    }
}
