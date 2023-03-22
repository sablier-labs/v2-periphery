// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import { IAllowanceTransfer } from "@permit2/interfaces/IAllowanceTransfer.sol";
import { ISablierV2Lockup } from "@sablier/v2-core/interfaces/ISablierV2Lockup.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";
import { ISablierV2LockupDynamic } from "@sablier/v2-core/interfaces/ISablierV2LockupDynamic.sol";
import { LockupLinear, LockupDynamic } from "@sablier/v2-core/types/DataTypes.sol";

import { ISablierV2ProxyTarget } from "./interfaces/ISablierV2ProxyTarget.sol";
import { IWETH9 } from "./interfaces/IWETH9.sol";
import { Errors } from "./libraries/Errors.sol";
import { Batch, Permit2Params } from "./types/DataTypes.sol";

/// @title SablierV2ProxyTarget
/// @notice Implements the {ISablierV2ProxyTarget} interface.
contract SablierV2ProxyTarget is ISablierV2ProxyTarget {
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////////////////
                                 SABLIER-V2-LOCKUP
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2ProxyTarget
    function batchCancel(Batch.Cancel[] calldata params) external {
        for (uint256 i = 0; i < params.length;) {
            // Interactions: cancel the stream.
            _cancel(params[i].lockup, params[i].streamId);

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
        }
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function batchCancelMultiple(Batch.CancelMultiple[] calldata params, IERC20[] calldata assets) external {
        _batchCancelMultiple(params, assets);
    }

    /// @dev Internal function that:
    /// 1. Queries the proxy balances of each asset before the streams are canceled.
    /// 2. Performs multiple external calls on {SablierV2Lockup-cancelMultiple}.
    /// 3. Transfers the returned amounts of each asset to proxy owner, if greater than zero.
    function _batchCancelMultiple(Batch.CancelMultiple[] calldata params, IERC20[] calldata assets) internal {
        uint256[] memory balancesBefore = _beforeCancelMultiple(assets);

        for (uint256 i = 0; i < params.length;) {
            // Interactions: cancel the streams.
            params[i].lockup.cancelMultiple(params[i].streamIds);

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
        }

        _afterCancelMultiple(balancesBefore, assets);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function cancel(ISablierV2Lockup lockup, uint256 streamId) external {
        _cancel(lockup, streamId);
    }

    /// @dev Internal function that:
    /// 1. Queries the asset of the stream.
    /// 2. Queries the return amount of the stream.
    /// 3. Performs an external call on {SablierV2Lockup-cancel}.
    /// 4. Transfers the return amount to proxy owner, if greater than zero.
    function _cancel(ISablierV2Lockup lockup, uint256 streamId) internal {
        // Interactions: query the asset.
        IERC20 asset = lockup.getAsset(streamId);

        // Interactions: query the return amount.
        uint256 returnAmount = lockup.returnableAmountOf(streamId);

        // Interactions: cancel the stream.
        lockup.cancel(streamId);

        // Interactions: transfer the return amount to proxy owner, if greater than zero.
        if (returnAmount > 0) {
            asset.safeTransfer(msg.sender, returnAmount);
        }
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function cancelMultiple(ISablierV2Lockup lockup, IERC20[] calldata assets, uint256[] calldata streamIds) external {
        _cancelMultiple(lockup, assets, streamIds);
    }

    /// @dev Internal function that:
    /// 1. Queries the proxy balances of each asset before the streams are canceled.
    /// 2. Performs an external call on {SablierV2Lockup-cancelMultiple}.
    /// 3. Transfers the return amounts sum to proxy owner, if greater than zero.
    function _cancelMultiple(
        ISablierV2Lockup lockup,
        IERC20[] calldata assets,
        uint256[] calldata streamIds
    )
        internal
    {
        uint256[] memory balancesBefore = _beforeCancelMultiple(assets);

        /// Interactions: cancel the streams.
        lockup.cancelMultiple(streamIds);

        _afterCancelMultiple(balancesBefore, assets);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function renounce(ISablierV2Lockup lockup, uint256 streamId) external {
        lockup.renounce(streamId);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function withdraw(ISablierV2Lockup lockup, uint256 streamId, address to, uint128 amount) external {
        lockup.withdraw(streamId, to, amount);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function withdrawMax(ISablierV2Lockup lockup, uint256 streamId, address to) external {
        lockup.withdrawMax(streamId, to);
    }

    /*//////////////////////////////////////////////////////////////////////////
                              SABLIER-V2-LOCKUP-LINEAR
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2ProxyTarget
    function cancelAndCreateWithDurations(
        ISablierV2Lockup lockup,
        ISablierV2LockupLinear linear,
        uint256 streamId,
        LockupLinear.CreateWithDurations calldata params,
        Permit2Params calldata permit2Params
    )
        external
        override
        returns (uint256 newStreamId)
    {
        _cancel(lockup, streamId);
        newStreamId = _createWithDurations(linear, params, permit2Params);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function cancelAndCreateWithRange(
        ISablierV2Lockup lockup,
        ISablierV2LockupLinear linear,
        uint256 streamId,
        LockupLinear.CreateWithRange calldata params,
        Permit2Params calldata permit2Params
    )
        external
        override
        returns (uint256 newStreamId)
    {
        _cancel(lockup, streamId);
        newStreamId = _createWithRange(linear, params, permit2Params);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function createWithDurations(
        ISablierV2LockupLinear linear,
        LockupLinear.CreateWithDurations calldata params,
        Permit2Params calldata permit2Params
    )
        external
        override
        returns (uint256 streamId)
    {
        streamId = _createWithDurations(linear, params, permit2Params);
    }

    /// @dev Internal function that:
    /// 1. Transfers funds from the `msg.sender` to the proxy contract via Permit2.
    /// 2. Approves the {SablierV2LockupLinear} contract to spend funds from proxy, if necessary.
    /// 3. Performs an external call on {SablierV2LockupLinear-createWithDeltas}.
    function _createWithDurations(
        ISablierV2LockupLinear linear,
        LockupLinear.CreateWithDurations calldata params,
        Permit2Params calldata permit2Params
    )
        internal
        returns (uint256 streamId)
    {
        _assetActions(address(linear), params.asset, params.totalAmount, permit2Params);
        streamId = linear.createWithDurations(params);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function createWithRange(
        ISablierV2LockupLinear linear,
        LockupLinear.CreateWithRange calldata params,
        Permit2Params calldata permit2Params
    )
        external
        override
        returns (uint256 streamId)
    {
        streamId = _createWithRange(linear, params, permit2Params);
    }

    /// @dev Internal function that:
    /// 1. Transfers funds from the `msg.sender` to the proxy contract via Permit2.
    /// 2. Approves the {SablierV2LockupLinear} contract to spend funds from proxy, if necessary.
    /// 3. Performs an external call on {SablierV2LockupLinear-createWithRange}.
    function _createWithRange(
        ISablierV2LockupLinear linear,
        LockupLinear.CreateWithRange calldata params,
        Permit2Params calldata permit2Params
    )
        internal
        returns (uint256 streamId)
    {
        _assetActions(address(linear), params.asset, params.totalAmount, permit2Params);
        streamId = linear.createWithRange(params);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function batchCreateWithDurations(
        ISablierV2LockupLinear linear,
        IERC20 asset,
        uint128 totalAmount,
        Batch.CreateWithDurations[] calldata params,
        Permit2Params calldata permit2Params
    )
        external
        override
        returns (uint256[] memory streamIds)
    {
        uint128 amountsSum;
        uint256 count = params.length;
        uint256 i;

        // Calculate the params amounts summed up.
        for (i = 0; i < count;) {
            amountsSum += params[i].amount;

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
        }

        // Checks: the `totalAmount` is zero and if it's equal to the sum of the `params.amount`.
        _checkBatchCreateParams(totalAmount, amountsSum);

        // Interactions: perform the ERC-20 transfer and approve {SablierV2LockupLinear} to spend the amount of assets.
        _assetActions(address(linear), asset, totalAmount, permit2Params);

        // Declare an array of `count` length to avoid "Index out of bounds error".
        uint256[] memory _streamIds = new uint256[](count);
        for (i = 0; i < count;) {
            // Interactions: make the external call.
            _streamIds[i] = linear.createWithDurations(
                LockupLinear.CreateWithDurations({
                    asset: asset,
                    broker: params[i].broker,
                    cancelable: params[i].cancelable,
                    durations: params[i].durations,
                    recipient: params[i].recipient,
                    sender: params[i].sender,
                    totalAmount: params[i].amount
                })
            );

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
        }

        streamIds = _streamIds;
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function batchCreateWithRange(
        ISablierV2LockupLinear linear,
        IERC20 asset,
        uint128 totalAmount,
        Batch.CreateWithRange[] calldata params,
        Permit2Params calldata permit2Params
    )
        external
        override
        returns (uint256[] memory streamIds)
    {
        uint128 amountsSum;
        uint256 count = params.length;
        uint256 i;

        // Calculate the params amounts summed up.
        for (i = 0; i < count;) {
            amountsSum += params[i].amount;
            unchecked {
                i += 1;
            }
        }

        // Checks: the `totalAmount` is zero and if it's equal to the sum of the `params.amount`.
        _checkBatchCreateParams(totalAmount, amountsSum);

        // Interactions: perform the ERC-20 transfer and approve {SablierV2LockupLinear} to spend the amount of assets.
        _assetActions(address(linear), asset, totalAmount, permit2Params);

        // Declare an array of `count` length to avoid "Index out of bounds error".
        uint256[] memory _streamIds = new uint256[](count);
        for (i = 0; i < count;) {
            // Interactions: make the external call.
            _streamIds[i] = linear.createWithRange(
                LockupLinear.CreateWithRange({
                    asset: asset,
                    broker: params[i].broker,
                    cancelable: params[i].cancelable,
                    range: params[i].range,
                    recipient: params[i].recipient,
                    sender: params[i].sender,
                    totalAmount: params[i].amount
                })
            );

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
        }

        streamIds = _streamIds;
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function wrapEtherAndCreateWithDurations(
        ISablierV2LockupLinear linear,
        IWETH9 weth9,
        LockupLinear.CreateWithDurations memory params
    )
        external
        payable
        override
        returns (uint256 streamId)
    {
        params.asset = weth9;
        // This cast is safe because realistically the total supply of ETH will not exceed 2^128-1.
        params.totalAmount = uint128(msg.value);

        // Interactions: deposit the Ether into the WETH9 contract.
        weth9.deposit{ value: msg.value }();

        _approveLockup(address(linear), weth9, params.totalAmount);
        streamId = linear.createWithDurations(params);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function wrapEtherAndCreateWithRange(
        ISablierV2LockupLinear linear,
        IWETH9 weth9,
        LockupLinear.CreateWithRange memory params
    )
        external
        payable
        override
        returns (uint256 streamId)
    {
        params.asset = weth9;
        // This cast is safe because realistically the total supply of ETH will not exceed 2^128-1.
        params.totalAmount = uint128(msg.value);

        // Interactions: deposit the Ether into the WETH9 contract.
        weth9.deposit{ value: msg.value }();

        _approveLockup(address(linear), weth9, params.totalAmount);
        streamId = linear.createWithRange(params);
    }

    /*//////////////////////////////////////////////////////////////////////////
                               SABLIER-V2-LOCKUP-PRO
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2ProxyTarget
    function cancelAndCreateWithDeltas(
        ISablierV2Lockup lockup,
        ISablierV2LockupDynamic dynamic,
        uint256 streamId,
        LockupDynamic.CreateWithDeltas calldata params,
        Permit2Params calldata permit2Params
    )
        external
        override
        returns (uint256 newStreamId)
    {
        _cancel(lockup, streamId);
        newStreamId = _createWithDeltas(dynamic, params, permit2Params);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function cancelAndCreateWithMilestones(
        ISablierV2Lockup lockup,
        ISablierV2LockupDynamic dynamic,
        uint256 streamId,
        LockupDynamic.CreateWithMilestones calldata params,
        Permit2Params calldata permit2Params
    )
        external
        override
        returns (uint256 newStreamId)
    {
        _cancel(lockup, streamId);
        newStreamId = _createWithMilestones(dynamic, params, permit2Params);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function createWithDelta(
        ISablierV2LockupDynamic dynamic,
        LockupDynamic.CreateWithDeltas calldata params,
        Permit2Params calldata permit2Params
    )
        external
        override
        returns (uint256 streamId)
    {
        streamId = _createWithDeltas(dynamic, params, permit2Params);
    }

    /// @dev Internal function that:
    /// 1. Transfers funds from the `msg.sender` to the proxy contract via Permit2.
    /// 2. Approves the {SablierV2LockupDynamic} contract to spend funds from proxy, if necessary.
    /// 3. Performs an external call on {SablierV2LockupDynamic-createWithDeltas}.
    function _createWithDeltas(
        ISablierV2LockupDynamic dynamic,
        LockupDynamic.CreateWithDeltas calldata params,
        Permit2Params calldata permit2Params
    )
        internal
        returns (uint256 streamId)
    {
        _assetActions(address(dynamic), params.asset, params.totalAmount, permit2Params);
        streamId = dynamic.createWithDeltas(params);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function createWithMilestones(
        ISablierV2LockupDynamic dynamic,
        LockupDynamic.CreateWithMilestones calldata params,
        Permit2Params calldata permit2Params
    )
        external
        override
        returns (uint256 streamId)
    {
        streamId = _createWithMilestones(dynamic, params, permit2Params);
    }

    /// @dev Internal function that:
    /// 1. Transfers funds from the `msg.sender` to the proxy contract via Permit2.
    /// 2. Approves the {SablierV2LockupDynamic} contract to spend funds from proxy, if necessary.
    /// 3. Performs an external call on {SablierV2LockupDynamic-createWithMilestones}.
    function _createWithMilestones(
        ISablierV2LockupDynamic dynamic,
        LockupDynamic.CreateWithMilestones calldata params,
        Permit2Params calldata permit2Params
    )
        internal
        returns (uint256 streamId)
    {
        _assetActions(address(dynamic), params.asset, params.totalAmount, permit2Params);
        streamId = dynamic.createWithMilestones(params);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function batchCreateWithDeltas(
        ISablierV2LockupDynamic dynamic,
        IERC20 asset,
        uint128 totalAmount,
        Batch.CreateWithDeltas[] calldata params,
        Permit2Params calldata permit2Params
    )
        external
        override
        returns (uint256[] memory streamIds)
    {
        uint128 amountsSum;
        uint256 count = params.length;
        uint256 i;

        // Calculate the params amounts summed up.
        for (i = 0; i < count;) {
            amountsSum += params[i].amount;
            unchecked {
                i += 1;
            }
        }

        // Checks: the `totalAmount` is zero and if it's equal to the sum of the `params.amount`.
        _checkBatchCreateParams(totalAmount, amountsSum);

        // Interactions: perform the ERC-20 transfer and approve {SablierV2LockupDynamic} to spend the amount of assets.
        _assetActions(address(dynamic), asset, totalAmount, permit2Params);

        // Declare an array of `count` length to avoid "Index out of bounds error".
        uint256[] memory _streamIds = new uint256[](count);
        for (i = 0; i < count;) {
            // Interactions: make the external call.
            _streamIds[i] = dynamic.createWithDeltas(
                LockupDynamic.CreateWithDeltas({
                    asset: asset,
                    broker: params[i].broker,
                    cancelable: params[i].cancelable,
                    recipient: params[i].recipient,
                    segments: params[i].segments,
                    sender: params[i].sender,
                    totalAmount: params[i].amount
                })
            );

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
        }

        streamIds = _streamIds;
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function batchCreateWithMilestones(
        ISablierV2LockupDynamic dynamic,
        IERC20 asset,
        uint128 totalAmount,
        Batch.CreateWithMilestones[] calldata params,
        Permit2Params calldata permit2Params
    )
        external
        override
        returns (uint256[] memory streamIds)
    {
        uint128 amountsSum;
        uint256 count = params.length;
        uint256 i;

        // Calculate the params amounts summed up.
        for (i = 0; i < count;) {
            amountsSum += params[i].amount;
            unchecked {
                i += 1;
            }
        }

        // Checks: the `totalAmount` is zero and if it's equal to the sum of the `params.amount`.
        _checkBatchCreateParams(totalAmount, amountsSum);

        // Interactions: perform the ERC-20 transfer and approve {SablierV2LockupDynamic} to spend the amount of assets.
        _assetActions(address(dynamic), asset, totalAmount, permit2Params);

        // Declare an array of `count` length to avoid "Index out of bounds error".
        uint256[] memory _streamIds = new uint256[](count);
        for (i = 0; i < count;) {
            // Interactions: make the external call.
            _streamIds[i] = dynamic.createWithMilestones(
                LockupDynamic.CreateWithMilestones({
                    asset: asset,
                    broker: params[i].broker,
                    cancelable: params[i].cancelable,
                    recipient: params[i].recipient,
                    segments: params[i].segments,
                    sender: params[i].sender,
                    startTime: params[i].startTime,
                    totalAmount: params[i].amount
                })
            );

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
        }

        streamIds = _streamIds;
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function wrapEtherAndCreateWithDeltas(
        ISablierV2LockupDynamic dynamic,
        IWETH9 weth9,
        LockupDynamic.CreateWithDeltas memory params
    )
        external
        payable
        override
        returns (uint256 streamId)
    {
        params.asset = weth9;
        // This cast is safe because realistically the total supply of ETH will not exceed 2^128-1.
        params.totalAmount = uint128(msg.value);

        // Interactions: deposit the Ether into the WETH9 contract.
        weth9.deposit{ value: msg.value }();

        _approveLockup(address(dynamic), weth9, params.totalAmount);
        streamId = dynamic.createWithDeltas(params);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function wrapEtherAndCreateWithMilestones(
        ISablierV2LockupDynamic dynamic,
        IWETH9 weth9,
        LockupDynamic.CreateWithMilestones memory params
    )
        external
        payable
        override
        returns (uint256 streamId)
    {
        params.asset = weth9;
        // This cast is safe because realistically the total supply of ETH will not exceed 2^128-1.
        params.totalAmount = uint128(msg.value);

        // Interactions: deposit the Ether into the WETH9 contract.
        weth9.deposit{ value: msg.value }();

        _approveLockup(address(dynamic), weth9, params.totalAmount);
        streamId = dynamic.createWithMilestones(params);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  HELPER FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Helper function to transfer funds after the cancel multiple call, if any.
    function _afterCancelMultiple(uint256[] memory balancesBefore, IERC20[] calldata assets) internal {
        uint256 balanceAfter;
        uint256 balanceDelta;
        for (uint256 i = 0; i < assets.length;) {
            // Calculate the balance delta.
            balanceAfter = assets[i].balanceOf(address(this));
            balanceDelta = balanceAfter - balancesBefore[i];

            // Interactions: transfer the balance delta to proxy owner, if greater than zero.
            if (balanceDelta > 0) {
                assets[i].safeTransfer(msg.sender, balanceDelta);
            }

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
        }
    }

    /// @dev Helper function that transfers `amount` funds from `msg.sender` to `address(this)` via Permit2
    /// and approves `amount` to `lockup`, if necessary.
    function _assetActions(
        address lockup,
        IERC20 asset,
        uint160 amount,
        Permit2Params calldata permit2Params
    )
        internal
    {
        /// Interactions: query the nonce for `msg.sender`.
        (,, uint48 nonce) = permit2Params.permit2.allowance(msg.sender, address(asset), address(this));

        /// Declare the `PermitSingle` struct used in `permit` function.
        IAllowanceTransfer.PermitSingle memory permitSingle = IAllowanceTransfer.PermitSingle({
            details: IAllowanceTransfer.PermitDetails({
                token: address(asset),
                amount: amount,
                expiration: permit2Params.expiration,
                nonce: nonce
            }),
            spender: address(this),
            sigDeadline: permit2Params.sigDeadline
        });

        /// Interactions: permit the proxy to spend funds from `msg.sender`.
        permit2Params.permit2.permit(msg.sender, permitSingle, permit2Params.signature);

        /// Interactions: transfer funds from `msg.sender` to proxy.
        permit2Params.permit2.transferFrom(msg.sender, address(this), amount, address(asset));

        _approveLockup(lockup, asset, amount);
    }

    /// @dev Helper function to approve `lockup` to spend `amount` of `asset`, if necessary.
    function _approveLockup(address lockup, IERC20 asset, uint256 amount) internal {
        /// Interactions: query the allownace of the proxy for `lockup`
        /// and approve `lockup`, if necessary.
        uint256 allowance = asset.allowance(address(this), lockup);
        if (allowance < amount) {
            asset.approve(lockup, type(uint256).max);
        }
    }

    /// @dev Helper function to query the proxy balances for `assets` before the cancel multiple call.
    function _beforeCancelMultiple(IERC20[] calldata assets) internal view returns (uint256[] memory balancesBefore) {
        uint256 assetsCount = assets.length;
        uint256[] memory _balancesBefore = new uint256[](assetsCount);
        for (uint256 i = 0; i < assetsCount;) {
            // Interactions: query the proxy balances.
            _balancesBefore[i] = assets[i].balanceOf(address(this));

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
        }

        balancesBefore = _balancesBefore;
    }

    /// @dev Checks the arguments of the batch create functions.
    function _checkBatchCreateParams(uint128 totalAmount, uint128 amountsSum) internal pure {
        // Checks: the total amount is not zero.
        if (totalAmount == 0) {
            revert Errors.SablierV2ProxyTarget_TotalAmountZero();
        }

        /// Checks: the total amount is equal to the parameters amounts summed up.
        if (amountsSum != totalAmount) {
            revert Errors.SablierV2ProxyTarget_TotalAmountNotEqualToAmountsSum(totalAmount, amountsSum);
        }
    }
}
