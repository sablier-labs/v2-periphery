// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { PRBProxyStorage } from "@prb/proxy/abstracts/PRBProxyStorage.sol";
import { ISablierV2Lockup } from "@sablier/v2-core/interfaces/ISablierV2Lockup.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";
import { ISablierV2LockupDynamic } from "@sablier/v2-core/interfaces/ISablierV2LockupDynamic.sol";
import { LockupDynamic, LockupLinear } from "@sablier/v2-core/types/DataTypes.sol";
import { IAllowanceTransfer } from "permit2/interfaces/IAllowanceTransfer.sol";

import { OnlyDelegateCall } from "./abstracts/OnlyDelegateCall.sol";
import { ISablierV2ProxyTarget } from "./interfaces/ISablierV2ProxyTarget.sol";
import { IWrappedNativeAsset } from "./interfaces/IWrappedNativeAsset.sol";
import { Errors } from "./libraries/Errors.sol";
import { Batch, Permit2Params } from "./types/DataTypes.sol";

/*

███████╗ █████╗ ██████╗ ██╗     ██╗███████╗██████╗     ██╗   ██╗██████╗
██╔════╝██╔══██╗██╔══██╗██║     ██║██╔════╝██╔══██╗    ██║   ██║╚════██╗
███████╗███████║██████╔╝██║     ██║█████╗  ██████╔╝    ██║   ██║ █████╔╝
╚════██║██╔══██║██╔══██╗██║     ██║██╔══╝  ██╔══██╗    ╚██╗ ██╔╝██╔═══╝
███████║██║  ██║██████╔╝███████╗██║███████╗██║  ██║     ╚████╔╝ ███████╗
╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝╚══════╝╚═╝  ╚═╝      ╚═══╝  ╚══════╝

██████╗ ██████╗  ██████╗ ██╗  ██╗██╗   ██╗    ████████╗ █████╗ ██████╗  ██████╗ ███████╗████████╗
██╔══██╗██╔══██╗██╔═══██╗╚██╗██╔╝╚██╗ ██╔╝    ╚══██╔══╝██╔══██╗██╔══██╗██╔════╝ ██╔════╝╚══██╔══╝
██████╔╝██████╔╝██║   ██║ ╚███╔╝  ╚████╔╝        ██║   ███████║██████╔╝██║  ███╗█████╗     ██║
██╔═══╝ ██╔══██╗██║   ██║ ██╔██╗   ╚██╔╝         ██║   ██╔══██║██╔══██╗██║   ██║██╔══╝     ██║
██║     ██║  ██║╚██████╔╝██╔╝ ██╗   ██║          ██║   ██║  ██║██║  ██║╚██████╔╝███████╗   ██║
╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝          ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝

*/

/// @title SablierV2ProxyTarget
/// @notice See the documentation in {ISablierV2ProxyTarget}.
contract SablierV2ProxyTarget is
    ISablierV2ProxyTarget, // 0 inherited components
    OnlyDelegateCall, // 0 inherited components
    PRBProxyStorage // 1 inherited component
{
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////////////////
                                 SABLIER-V2-LOCKUP
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2ProxyTarget
    function batchCancelMultiple(
        Batch.CancelMultiple[] calldata batch,
        IERC20[] calldata assets
    )
        external
        onlyDelegateCall
    {
        // Check that the batch size is not zero.
        uint256 batchSize = batch.length;
        if (batchSize == 0) {
            revert Errors.SablierV2ProxyTarget_BatchSizeZero();
        }

        // Load the balances before the cancellations.
        uint256[] memory initialBalances = _getBalances(assets);

        for (uint256 i = 0; i < batchSize;) {
            // Cancel the streams.
            batch[i].lockup.cancelMultiple(batch[i].streamIds);

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
        }

        // Transfer the balance differences to the proxy owner.
        _postMultipleCancellations(initialBalances, assets);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function cancel(ISablierV2Lockup lockup, uint256 streamId) public onlyDelegateCall {
        // Retrieve the asset used for streaming.
        IERC20 asset = lockup.getAsset(streamId);

        // Retrieve the refunded amount.
        uint256 refundedAmount = lockup.refundableAmountOf(streamId);

        // Cancel the stream.
        lockup.cancel(streamId);

        // Forward the refunded amount to the proxy owner. This cannot be zero because settled streams cannot be
        // canceled.
        asset.safeTransfer({ to: owner, value: refundedAmount });
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function cancelMultiple(
        ISablierV2Lockup lockup,
        IERC20[] calldata assets,
        uint256[] calldata streamIds
    )
        external
        onlyDelegateCall
    {
        // Load the balances before the cancellations.
        uint256[] memory initialBalances = _getBalances(assets);

        // Cancel the streams.
        lockup.cancelMultiple(streamIds);

        // Transfer the balance differences to the proxy owner.
        _postMultipleCancellations(initialBalances, assets);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function renounce(ISablierV2Lockup lockup, uint256 streamId) external onlyDelegateCall {
        lockup.renounce(streamId);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function withdraw(
        ISablierV2Lockup lockup,
        uint256 streamId,
        address to,
        uint128 amount
    )
        external
        onlyDelegateCall
    {
        lockup.withdraw(streamId, to, amount);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function withdrawMax(ISablierV2Lockup lockup, uint256 streamId, address to) external onlyDelegateCall {
        lockup.withdrawMax(streamId, to);
    }

    /*//////////////////////////////////////////////////////////////////////////
                              SABLIER-V2-LOCKUP-LINEAR
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2ProxyTarget
    function batchCreateWithDurations(
        ISablierV2LockupLinear lockupLinear,
        IERC20 asset,
        Batch.CreateWithDurations[] calldata batch,
        Permit2Params calldata permit2Params
    )
        external
        override
        onlyDelegateCall
        returns (uint256[] memory streamIds)
    {
        // Check that the batch size is not zero.
        uint256 batchSize = batch.length;
        if (batchSize == 0) {
            revert Errors.SablierV2ProxyTarget_BatchSizeZero();
        }

        // Calculate the sum of all of stream amounts. It is safe to use unchecked addition because one of the create
        // transactions will revert if there is overflow.
        uint256 i;
        uint128 transferAmount;
        for (i = 0; i < batchSize;) {
            unchecked {
                transferAmount += batch[i].totalAmount;
                i += 1;
            }
        }

        // Transfers the assets to the proxy and approve the Sablier contract to spend them.
        _transferAndApprove(address(lockupLinear), asset, transferAmount, permit2Params);

        // Create a stream for each element in the parameter array.
        streamIds = new uint256[](batchSize);
        for (i = 0; i < batchSize;) {
            // Create the stream.
            streamIds[i] = lockupLinear.createWithDurations(
                LockupLinear.CreateWithDurations({
                    asset: asset,
                    broker: batch[i].broker,
                    cancelable: batch[i].cancelable,
                    durations: batch[i].durations,
                    recipient: batch[i].recipient,
                    sender: batch[i].sender,
                    totalAmount: batch[i].totalAmount
                })
            );

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
        }
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function batchCreateWithRange(
        ISablierV2LockupLinear lockupLinear,
        IERC20 asset,
        Batch.CreateWithRange[] calldata batch,
        Permit2Params calldata permit2Params
    )
        external
        override
        onlyDelegateCall
        returns (uint256[] memory streamIds)
    {
        // Check that the batch is not empty.
        uint256 batchSize = batch.length;
        if (batchSize == 0) {
            revert Errors.SablierV2ProxyTarget_BatchSizeZero();
        }

        // Calculate the sum of all of stream amounts. It is safe to use unchecked addition because one of the create
        // transactions will revert if there is overflow.
        uint256 i;
        uint128 transferAmount;
        for (i = 0; i < batchSize;) {
            unchecked {
                transferAmount += batch[i].totalAmount;
                i += 1;
            }
        }

        // Transfers the assets to the proxy and approve the Sablier contract to spend them.
        _transferAndApprove(address(lockupLinear), asset, transferAmount, permit2Params);

        // Create a stream for each element in the parameter array.
        streamIds = new uint256[](batchSize);
        for (i = 0; i < batchSize;) {
            // Create the stream.
            streamIds[i] = lockupLinear.createWithRange(
                LockupLinear.CreateWithRange({
                    asset: asset,
                    broker: batch[i].broker,
                    cancelable: batch[i].cancelable,
                    range: batch[i].range,
                    recipient: batch[i].recipient,
                    sender: batch[i].sender,
                    totalAmount: batch[i].totalAmount
                })
            );

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
        }
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function cancelAndCreateWithDurations(
        ISablierV2Lockup lockup,
        uint256 streamId,
        ISablierV2LockupLinear lockupLinear,
        LockupLinear.CreateWithDurations calldata createParams,
        Permit2Params calldata permit2Params
    )
        external
        override
        onlyDelegateCall
        returns (uint256 newStreamId)
    {
        cancel(lockup, streamId);
        newStreamId = createWithDurations(lockupLinear, createParams, permit2Params);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function cancelAndCreateWithRange(
        ISablierV2Lockup lockup,
        uint256 streamId,
        ISablierV2LockupLinear lockupLinear,
        LockupLinear.CreateWithRange calldata createParams,
        Permit2Params calldata permit2Params
    )
        external
        override
        onlyDelegateCall
        returns (uint256 newStreamId)
    {
        cancel(lockup, streamId);
        newStreamId = createWithRange(lockupLinear, createParams, permit2Params);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function createWithDurations(
        ISablierV2LockupLinear lockupLinear,
        LockupLinear.CreateWithDurations calldata createParams,
        Permit2Params calldata permit2Params
    )
        public
        override
        onlyDelegateCall
        returns (uint256 streamId)
    {
        _transferAndApprove(address(lockupLinear), createParams.asset, createParams.totalAmount, permit2Params);
        streamId = lockupLinear.createWithDurations(createParams);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function createWithRange(
        ISablierV2LockupLinear lockupLinear,
        LockupLinear.CreateWithRange calldata createParams,
        Permit2Params calldata permit2Params
    )
        public
        override
        onlyDelegateCall
        returns (uint256 streamId)
    {
        _transferAndApprove(address(lockupLinear), createParams.asset, createParams.totalAmount, permit2Params);
        streamId = lockupLinear.createWithRange(createParams);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function wrapAndCreateWithDurations(
        ISablierV2LockupLinear lockupLinear,
        LockupLinear.CreateWithDurations memory createParams
    )
        external
        payable
        override
        onlyDelegateCall
        returns (uint256 streamId)
    {
        // All production chains have a native asset with a circulating supply much smaller than 2^128.
        createParams.totalAmount = uint128(msg.value);

        // Wrap the native asset payment in ERC-20 form.
        IWrappedNativeAsset(address(createParams.asset)).deposit{ value: msg.value }();

        // Approve the Sablier contract to spend funds.
        _approve(address(lockupLinear), createParams.asset, createParams.totalAmount);

        // Create the stream.
        streamId = lockupLinear.createWithDurations(createParams);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function wrapAndCreateWithRange(
        ISablierV2LockupLinear lockupLinear,
        LockupLinear.CreateWithRange memory createParams
    )
        external
        payable
        override
        onlyDelegateCall
        returns (uint256 streamId)
    {
        // All production chains have a native asset with a circulating supply much smaller than 2^128.
        createParams.totalAmount = uint128(msg.value);

        // Wrap the native asset payment in ERC-20 form.
        IWrappedNativeAsset(address(createParams.asset)).deposit{ value: msg.value }();

        // Approve the Sablier contract to spend funds.
        _approve(address(lockupLinear), createParams.asset, createParams.totalAmount);

        // Create the stream.
        streamId = lockupLinear.createWithRange(createParams);
    }

    /*//////////////////////////////////////////////////////////////////////////
                             SABLIER-V2-LOCKUP-DYNAMIC
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2ProxyTarget
    function batchCreateWithDeltas(
        ISablierV2LockupDynamic dynamic,
        IERC20 asset,
        Batch.CreateWithDeltas[] calldata batch,
        Permit2Params calldata permit2Params
    )
        external
        override
        onlyDelegateCall
        returns (uint256[] memory streamIds)
    {
        // Check that the batch size is not zero.
        uint256 batchSize = batch.length;
        if (batchSize == 0) {
            revert Errors.SablierV2ProxyTarget_BatchSizeZero();
        }

        // Calculate the sum of all of stream amounts. It is safe to use unchecked addition because one of the create
        // transactions will revert if there is overflow.
        uint256 i;
        uint128 transferAmount;
        for (i = 0; i < batchSize;) {
            unchecked {
                transferAmount += batch[i].totalAmount;
                i += 1;
            }
        }

        // Perform the ERC-20 transfer and approve {SablierV2LockupDynamic} to spend the amount of assets.
        _transferAndApprove(address(dynamic), asset, transferAmount, permit2Params);

        // Create a stream for each element in the parameter array.
        streamIds = new uint256[](batchSize);
        for (i = 0; i < batchSize;) {
            // Create the stream.
            streamIds[i] = dynamic.createWithDeltas(
                LockupDynamic.CreateWithDeltas({
                    asset: asset,
                    broker: batch[i].broker,
                    cancelable: batch[i].cancelable,
                    recipient: batch[i].recipient,
                    segments: batch[i].segments,
                    sender: batch[i].sender,
                    totalAmount: batch[i].totalAmount
                })
            );

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
        }
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function batchCreateWithMilestones(
        ISablierV2LockupDynamic dynamic,
        IERC20 asset,
        Batch.CreateWithMilestones[] calldata batch,
        Permit2Params calldata permit2Params
    )
        external
        override
        onlyDelegateCall
        returns (uint256[] memory streamIds)
    {
        // Check that the batch size is not zero.
        uint256 batchSize = batch.length;
        if (batchSize == 0) {
            revert Errors.SablierV2ProxyTarget_BatchSizeZero();
        }

        // Calculate the sum of all of stream amounts. It is safe to use unchecked addition because one of the create
        // transactions will revert if there is overflow.
        uint256 i;
        uint128 transferAmount;
        for (i = 0; i < batchSize;) {
            unchecked {
                transferAmount += batch[i].totalAmount;
                i += 1;
            }
        }

        // Perform the ERC-20 transfer and approve {SablierV2LockupDynamic} to spend the amount of assets.
        _transferAndApprove(address(dynamic), asset, transferAmount, permit2Params);

        // Create a stream for each element in the parameter array.
        streamIds = new uint256[](batchSize);
        for (i = 0; i < batchSize;) {
            // Create the stream.
            streamIds[i] = dynamic.createWithMilestones(
                LockupDynamic.CreateWithMilestones({
                    asset: asset,
                    broker: batch[i].broker,
                    cancelable: batch[i].cancelable,
                    recipient: batch[i].recipient,
                    segments: batch[i].segments,
                    sender: batch[i].sender,
                    startTime: batch[i].startTime,
                    totalAmount: batch[i].totalAmount
                })
            );

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
        }
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function cancelAndCreateWithDeltas(
        ISablierV2Lockup lockup,
        uint256 streamId,
        ISablierV2LockupDynamic dynamic,
        LockupDynamic.CreateWithDeltas calldata createParams,
        Permit2Params calldata permit2Params
    )
        external
        override
        onlyDelegateCall
        returns (uint256 newStreamId)
    {
        cancel(lockup, streamId);
        newStreamId = createWithDeltas(dynamic, createParams, permit2Params);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function cancelAndCreateWithMilestones(
        ISablierV2Lockup lockup,
        uint256 streamId,
        ISablierV2LockupDynamic dynamic,
        LockupDynamic.CreateWithMilestones calldata createParams,
        Permit2Params calldata permit2Params
    )
        external
        override
        onlyDelegateCall
        returns (uint256 newStreamId)
    {
        cancel(lockup, streamId);
        newStreamId = createWithMilestones(dynamic, createParams, permit2Params);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function createWithDeltas(
        ISablierV2LockupDynamic dynamic,
        LockupDynamic.CreateWithDeltas calldata createParams,
        Permit2Params calldata permit2Params
    )
        public
        override
        onlyDelegateCall
        returns (uint256 streamId)
    {
        _transferAndApprove(address(dynamic), createParams.asset, createParams.totalAmount, permit2Params);
        streamId = dynamic.createWithDeltas(createParams);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function createWithMilestones(
        ISablierV2LockupDynamic dynamic,
        LockupDynamic.CreateWithMilestones calldata createParams,
        Permit2Params calldata permit2Params
    )
        public
        override
        onlyDelegateCall
        returns (uint256 streamId)
    {
        _transferAndApprove(address(dynamic), createParams.asset, createParams.totalAmount, permit2Params);
        streamId = dynamic.createWithMilestones(createParams);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function wrapAndCreateWithDeltas(
        ISablierV2LockupDynamic dynamic,
        LockupDynamic.CreateWithDeltas memory createParams
    )
        external
        payable
        override
        onlyDelegateCall
        returns (uint256 streamId)
    {
        // All production chains have a native asset with a circulating supply much smaller than 2^128.
        createParams.totalAmount = uint128(msg.value);

        // Wrap the native asset payment in ERC-20 form.
        IWrappedNativeAsset(address(createParams.asset)).deposit{ value: msg.value }();

        // Approve the Sablier contract to spend funds.
        _approve(address(dynamic), createParams.asset, createParams.totalAmount);

        // Create the stream.
        streamId = dynamic.createWithDeltas(createParams);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function wrapAndCreateWithMilestones(
        ISablierV2LockupDynamic dynamic,
        LockupDynamic.CreateWithMilestones memory createParams
    )
        external
        payable
        override
        onlyDelegateCall
        returns (uint256 streamId)
    {
        // All production chains have a native asset with a circulating supply much smaller than 2^128.
        createParams.totalAmount = uint128(msg.value);

        // Wrap the native asset payment in ERC-20 form.
        IWrappedNativeAsset(address(createParams.asset)).deposit{ value: msg.value }();

        // Approve the Sablier contract to spend funds.
        _approve(address(dynamic), createParams.asset, createParams.totalAmount);

        // Create the stream.
        streamId = dynamic.createWithMilestones(createParams);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  HELPER FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Helper function to approve a Sablier contract to spend funds from the proxy. If the current allowance
    /// is insufficient, this function approves Sablier to spend the exact `amount`.
    /// The {SafeERC20.forceApprove} function is used to handle special ERC-20 assets (e.g. USDT) that require the
    /// current allowance to be zero before setting it to a non-zero value.
    function _approve(address sablierContract, IERC20 asset, uint256 amount) internal {
        uint256 allowance = asset.allowance({ owner: address(this), spender: sablierContract });
        if (allowance < amount) {
            asset.forceApprove({ spender: sablierContract, value: amount });
        }
    }

    /// @dev Helper function to retrieve the proxy's balance for the provided assets.
    function _getBalances(IERC20[] calldata assets) internal view returns (uint256[] memory initialBalances) {
        uint256 assetCount = assets.length;
        initialBalances = new uint256[](assetCount);
        for (uint256 i = 0; i < assetCount;) {
            initialBalances[i] = assets[i].balanceOf(address(this));
            unchecked {
                i += 1;
            }
        }
    }

    /// @dev Shared logic between {cancelMultiple} and {batchCancelMultiple}.
    function _postMultipleCancellations(uint256[] memory initialBalances, IERC20[] calldata assets) internal {
        uint256 assetCount = assets.length;
        uint256 balanceFinal;
        uint256 balanceDelta;
        for (uint256 i = 0; i < assetCount;) {
            // Calculate the difference between the final and initial balances.
            balanceFinal = assets[i].balanceOf(address(this));
            balanceDelta = balanceFinal - initialBalances[i];

            // Forward the balance delta to the proxy owner. This cannot be zero because settled streams cannot be
            // canceled.
            assets[i].safeTransfer({ to: owner, value: balanceDelta });

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
        }
    }

    /// @dev Helper function to transfer funds from the proxy owner to the proxy using Permit2 and, if needed, approve
    /// the Sablier contract to spend funds from the proxy.
    function _transferAndApprove(
        address sablierContract,
        IERC20 asset,
        uint160 amount,
        Permit2Params calldata permit2Params
    )
        internal
    {
        // Retrieve the proxy owner.
        address owner_ = owner;

        // Permit the proxy to spend funds from the proxy owner.
        permit2Params.permit2.permit({
            owner: owner_,
            permitSingle: permit2Params.permitSingle,
            signature: permit2Params.signature
        });

        // Transfer funds from the proxy owner to the proxy.
        permit2Params.permit2.transferFrom({ from: owner_, to: address(this), amount: amount, token: address(asset) });

        // Approve the Sablier contract to spend funds.
        _approve(sablierContract, asset, amount);
    }
}
