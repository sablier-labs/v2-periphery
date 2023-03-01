// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { IAllowanceTransfer } from "@permit2/interfaces/IAllowanceTransfer.sol";
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

            // Checks: the asset is the same for all streams.s
            streamAsset = lockup.getAsset(streamIds[i]);
            if (asset != streamAsset) {
                revert Errors.SablierV2ProxyTarget_CancelMultipleDifferentAsset(asset, streamAsset);
            }

            unchecked {
                i += 1;
            }
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                          INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Helper function that:
    /// 1. Gets the asset of the stream.
    /// 2. Gets the return amount of the stream.
    /// 3. Performs an external call on {SablierV2Lockup-cancel}.
    /// 4. Transfers the return amount to proxy owner, if greater than zero.
    function cancel(ISablierV2Lockup lockup, uint256 streamId) internal {
        // Interactions: get the asset.
        IERC20 asset = lockup.getAsset(streamId);

        // Interactions: get the return amount.
        uint256 returnAmount = lockup.returnableAmountOf(streamId);

        // Interactions: cancel the stream.
        lockup.cancel(streamId);

        // Interactions: transfer the return amount to proxy owner, if greater than zero.
        if (returnAmount > 0) {
            asset.safeTransfer(msg.sender, returnAmount);
        }
    }

    /// @dev Helper function that:
    /// 1. Checks the asset and calculates the return amounts sum.
    /// 2. Performs an external call on {SablierV2Lockup-cancelMultiple}.
    /// 3. Transfers the return amounts sum to proxy owner, if greater than zero.
    function cancelMultiple(ISablierV2Lockup lockup, IERC20 asset, uint256[] calldata streamIds) internal {
        // Checks and calculations: check the asset and calculate the return amounts sum.
        uint256 returnAmountsSum = checkAssetAndCalculateReturnAmountsSum(lockup, asset, streamIds);
        lockup.cancelMultiple(streamIds);

        // Interactions: transfer the return amounts sum to proxy owner, if greater than zero.
        if (returnAmountsSum > 0) {
            asset.safeTransfer(msg.sender, returnAmountsSum);
        }
    }

    /// @dev Checks the wrap function parameters and deposits the Ether in the WETH9 contract.
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

    /// @dev Helper function that:
    /// 1. Transfers funds from the `msg.sender` to the proxy contract via Permit2.
    /// 2. Approves the {SablierV2LockupPro} contract to spend funds from proxy.
    /// 3. Performs an external call on {SablierV2LockupPro-createWithDeltas}.
    function createWithDeltas(
        ISablierV2LockupPro pro,
        IAllowanceTransfer permit2,
        LockupPro.CreateWithDeltas calldata params
    ) internal returns (uint256 streamId) {
        transferAndApprove(permit2, address(pro), params.asset, params.totalAmount);
        streamId = pro.createWithDeltas(params);
    }

    /// @dev Helper function that:
    /// 1. Transfers funds from the `msg.sender` to the proxy contract via Permit2.
    /// 2. Approves the {SablierV2LockupLinear} contract to spend funds from proxy.
    /// 3. Performs an external call on {SablierV2LockupLinear-createWithDeltas}.
    function createWithDurations(
        ISablierV2LockupLinear linear,
        IAllowanceTransfer permit2,
        LockupLinear.CreateWithDurations calldata params
    ) internal returns (uint256 streamId) {
        transferAndApprove(permit2, address(linear), params.asset, params.totalAmount);
        streamId = linear.createWithDurations(params);
    }

    /// @dev Helper function that:
    /// 1. Transfers funds from the `msg.sender` to the proxy contract via Permit2.
    /// 2. Approves the {SablierV2LockupPro} contract to spend funds from proxy.
    /// 3. Performs an external call on {SablierV2LockupPro-createWithMilestones}.
    function createWithMilestones(
        ISablierV2LockupPro pro,
        IAllowanceTransfer permit2,
        LockupPro.CreateWithMilestones calldata params
    ) internal returns (uint256 streamId) {
        transferAndApprove(permit2, address(pro), params.asset, params.totalAmount);
        streamId = pro.createWithMilestones(params);
    }

    /// @dev Helper function that:
    /// 1. Transfers funds from the `msg.sender` to the proxy contract via Permit2.
    /// 2. Approves the {SablierV2LockupLinear} contract to spend funds from proxy.
    /// 3. Performs an external call on {SablierV2LockupLinear-createWithRange}.
    function createWithRange(
        ISablierV2LockupLinear linear,
        IAllowanceTransfer permit2,
        LockupLinear.CreateWithRange calldata params
    ) internal returns (uint256 streamId) {
        transferAndApprove(permit2, address(linear), params.asset, params.totalAmount);
        streamId = linear.createWithRange(params);
    }

    /// @dev Helper function that transfers `amount` funds from `msg.sender` to `address(this)` via Permit2
    /// and approves `amount` to `spender`, if necessary.
    function transferAndApprove(IAllowanceTransfer permit2, address spender, IERC20 asset, uint160 amount) internal {
        permit2.transferFrom(msg.sender, address(this), amount, address(asset));

        uint256 allowance = asset.allowance(address(this), spender);
        if (allowance < uint256(amount)) {
            asset.approve(spender, type(uint256).max);
        }
    }
}
