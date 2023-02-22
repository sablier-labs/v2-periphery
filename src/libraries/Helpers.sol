// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { ISignatureTransfer } from "@permit2/interfaces/ISignatureTransfer.sol";
import { SafeERC20 } from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import { ISablierV2Lockup } from "@sablier/v2-core/interfaces/ISablierV2Lockup.sol";
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
    function checkCreateMultipleParams(uint128 totalAmount, uint128 amountsSum) internal pure {
        // Checks: the total amount is not zero.
        if (totalAmount == 0) {
            revert Errors.SablierV2ProxyTarget_TotalAmountZero();
        }

        /// Checks: the total amount is equal to the parameters amounts summed up.
        if (amountsSum != totalAmount) {
            revert Errors.SablierV2ProxyTarget_TotalAmountNotEqualToAmountsSum(totalAmount, amountsSum);
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                          INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Helper function that performs an external call on {SablierV2Lockup-cancel}.
    function cancel(ISablierV2Lockup lockup, uint256 streamId) internal {
        IERC20 asset = lockup.getAsset(streamId);
        uint256 returnAmount = lockup.returnableAmountOf(streamId);
        lockup.cancel(streamId);
        if (returnAmount > 0) {
            asset.safeTransfer(msg.sender, returnAmount);
        }
    }

    /// @dev Helper function that performs an external call on {SablierV2Lockup-cancelMultiple}.
    function cancelMultiple(ISablierV2Lockup lockup, IERC20 asset, uint256[] calldata streamIds) internal {
        uint256 returnAmountsSum = checkAssetAndCalculateReturnAmountsSum(lockup, asset, streamIds);
        lockup.cancelMultiple(streamIds);
        if (returnAmountsSum > 0) {
            asset.safeTransfer(msg.sender, returnAmountsSum);
        }
    }

    /// @dev Helper function to check the asset and calculate the return amounts sum.
    function checkAssetAndCalculateReturnAmountsSum(
        ISablierV2Lockup lockup,
        IERC20 asset,
        uint256[] calldata streamIds
    ) internal view returns (uint256 returnAmountsSum) {
        uint256 count = streamIds.length;
        IERC20 streamAsset;

        for (uint256 i = 0; i < count; ) {
            returnAmountsSum += lockup.returnableAmountOf(streamIds[i]);

            streamAsset = lockup.getAsset(streamIds[i]);
            if (asset != streamAsset) {
                revert Errors.SablierV2ProxyTarget_CancelMultipleDifferentAsset(asset, streamAsset);
            }

            unchecked {
                i += 1;
            }
        }
    }

    /// @dev Checks the wrap function parameters and deposits the Ether into the WETH9 contract.
    function checkParamsAndDepositEther(IWETH9 weth9, IERC20 asset, uint256 amount) internal {
        // Checks: the asset is the actual WETH9 contract.
        if (asset != weth9) {
            revert Errors.SablierV2ProxyTarget_AssetNotWETH9(asset, weth9);
        }

        uint256 value = msg.value;

        // Checks: the amount of WETH9 is the same as the amount of Ether sent.
        if (amount != value) {
            revert Errors.SablierV2ProxyTarget_WrongEtherAmount(value, amount);
        }

        // Interactions: deposit the Ether into the WETH9 contract.
        weth9.deposit{ value: value }();
    }

    /// @dev Helper function that performs an external call on {SablierV2LockupPro-createWithDeltas}.
    function createWithDeltas(
        ISablierV2LockupPro pro,
        LockupPro.CreateWithDeltas calldata params
    ) internal returns (uint256 streamId) {
        transferAndApprove(address(pro), params.asset, params.totalAmount);
        streamId = pro.createWithDeltas(params);
    }

    /// @dev Helper function that performs an external call on {SablierV2LockupPro-createWithDurations}.
    function createWithDurations(
        ISablierV2LockupLinear linear,
        LockupLinear.CreateWithDurations calldata params
    ) internal returns (uint256 streamId) {
        transferAndApprove(address(linear), params.asset, params.totalAmount);
        streamId = linear.createWithDurations(params);
    }

    /// @dev Helper function that performs an external call on {SablierV2LockupPro-createWithMilestones}.
    function createWithMilestones(
        ISablierV2LockupPro pro,
        LockupPro.CreateWithMilestones calldata params
    ) internal returns (uint256 streamId) {
        transferAndApprove(address(pro), params.asset, params.totalAmount);
        streamId = pro.createWithMilestones(params);
    }

    /// @dev Helper function that performs an external call on {SablierV2LockupLinear-createWithRange}.
    function createWithRange(
        ISablierV2LockupLinear linear,
        LockupLinear.CreateWithRange calldata params
    ) internal returns (uint256 streamId) {
        transferAndApprove(address(linear), params.asset, params.totalAmount);
        streamId = linear.createWithRange(params);
    }

    /// @dev Helper function that transfers `value` funds from `msg.sender` to `address(this)`
    /// and approves `value` to `spender`.
    function transferAndApprove(address spender, IERC20 asset, uint256 value) internal {
        asset.safeTransferFrom({ from: msg.sender, to: address(this), value: value });

        uint256 allowance = asset.allowance(address(this), spender);
        if (allowance < value) {
            asset.approve(spender, type(uint256).max);
        }
    }
}
