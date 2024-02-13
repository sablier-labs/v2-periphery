// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { ISablierV2LockupDynamic } from "@sablier/v2-core/src/interfaces/ISablierV2LockupDynamic.sol";
import { LockupDynamic, LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { ISablierV2Batch } from "./interfaces/ISablierV2Batch.sol";
import { Errors } from "./libraries/Errors.sol";
import { Batch } from "./types/DataTypes.sol";

/// @title SablierV2Batch
/// @notice See the documentation in {ISablierV2Batch}.
contract SablierV2Batch is ISablierV2Batch {
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////////////////
                              SABLIER-V2-LOCKUP-LINEAR
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2Batch
    function createWithDurationsLL(
        ISablierV2LockupLinear lockupLinear,
        IERC20 asset,
        Batch.CreateWithDurationsLL[] calldata batch
    )
        external
        override
        returns (uint256[] memory streamIds)
    {
        // Check that the batch size is not zero.
        uint256 batchSize = batch.length;
        if (batchSize == 0) {
            revert Errors.SablierV2Batch_BatchSizeZero();
        }

        // Calculate the sum of all of stream amounts. It is safe to use unchecked addition because one of the create
        // transactions will revert if there is overflow.
        uint256 i;
        uint256 transferAmount;
        for (i = 0; i < batchSize; ++i) {
            unchecked {
                transferAmount += batch[i].totalAmount;
            }
        }

        // Transfers the assets to the batch and approves the Sablier contract to spend them.
        _handleTransfer(address(lockupLinear), asset, transferAmount);

        // Create a stream for each element in the parameter array.
        streamIds = new uint256[](batchSize);
        for (i = 0; i < batchSize; ++i) {
            // Create the stream.
            streamIds[i] = lockupLinear.createWithDurations(
                LockupLinear.CreateWithDurations({
                    sender: batch[i].sender,
                    recipient: batch[i].recipient,
                    totalAmount: batch[i].totalAmount,
                    asset: asset,
                    cancelable: batch[i].cancelable,
                    transferable: batch[i].transferable,
                    durations: batch[i].durations,
                    broker: batch[i].broker
                })
            );
        }
    }

    /// @inheritdoc ISablierV2Batch
    function createWithTimestampsLL(
        ISablierV2LockupLinear lockupLinear,
        IERC20 asset,
        Batch.CreateWithTimestampsLL[] calldata batch
    )
        external
        override
        returns (uint256[] memory streamIds)
    {
        // Check that the batch is not empty.
        uint256 batchSize = batch.length;
        if (batchSize == 0) {
            revert Errors.SablierV2Batch_BatchSizeZero();
        }

        // Calculate the sum of all of stream amounts. It is safe to use unchecked addition because one of the create
        // transactions will revert if there is overflow.
        uint256 i;
        uint256 transferAmount;
        for (i = 0; i < batchSize; ++i) {
            unchecked {
                transferAmount += batch[i].totalAmount;
            }
        }

        // Transfers the assets to the batch and approve the Sablier contract to spend them.
        _handleTransfer(address(lockupLinear), asset, transferAmount);

        // Create a stream for each element in the parameter array.
        streamIds = new uint256[](batchSize);
        for (i = 0; i < batchSize; ++i) {
            // Create the stream.
            streamIds[i] = lockupLinear.createWithTimestamps(
                LockupLinear.CreateWithTimestamps({
                    sender: batch[i].sender,
                    recipient: batch[i].recipient,
                    totalAmount: batch[i].totalAmount,
                    asset: asset,
                    cancelable: batch[i].cancelable,
                    transferable: batch[i].transferable,
                    range: batch[i].range,
                    broker: batch[i].broker
                })
            );
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                             SABLIER-V2-LOCKUP-DYNAMIC
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2Batch
    function createWithDurationsLD(
        ISablierV2LockupDynamic lockupDynamic,
        IERC20 asset,
        Batch.CreateWithDurationsLD[] calldata batch
    )
        external
        override
        returns (uint256[] memory streamIds)
    {
        // Check that the batch size is not zero.
        uint256 batchSize = batch.length;
        if (batchSize == 0) {
            revert Errors.SablierV2Batch_BatchSizeZero();
        }

        // Calculate the sum of all of stream amounts. It is safe to use unchecked addition because one of the create
        // transactions will revert if there is overflow.
        uint256 i;
        uint256 transferAmount;
        for (i = 0; i < batchSize; ++i) {
            unchecked {
                transferAmount += batch[i].totalAmount;
            }
        }

        // Perform the ERC-20 transfer and approve {SablierV2LockupDynamic} to spend the amount of assets.
        _handleTransfer(address(lockupDynamic), asset, transferAmount);

        // Create a stream for each element in the parameter array.
        streamIds = new uint256[](batchSize);
        for (i = 0; i < batchSize; ++i) {
            // Create the stream.
            streamIds[i] = lockupDynamic.createWithDurations(
                LockupDynamic.CreateWithDurations({
                    sender: batch[i].sender,
                    recipient: batch[i].recipient,
                    totalAmount: batch[i].totalAmount,
                    asset: asset,
                    cancelable: batch[i].cancelable,
                    transferable: batch[i].transferable,
                    segments: batch[i].segments,
                    broker: batch[i].broker
                })
            );
        }
    }

    /// @inheritdoc ISablierV2Batch
    function createWithTimestampsLD(
        ISablierV2LockupDynamic lockupDynamic,
        IERC20 asset,
        Batch.CreateWithTimestampsLD[] calldata batch
    )
        external
        override
        returns (uint256[] memory streamIds)
    {
        // Check that the batch size is not zero.
        uint256 batchSize = batch.length;
        if (batchSize == 0) {
            revert Errors.SablierV2Batch_BatchSizeZero();
        }

        // Calculate the sum of all of stream amounts. It is safe to use unchecked addition because one of the create
        // transactions will revert if there is overflow.
        uint256 i;
        uint256 transferAmount;
        for (i = 0; i < batchSize; ++i) {
            unchecked {
                transferAmount += batch[i].totalAmount;
            }
        }

        // Perform the ERC-20 transfer and approve {SablierV2LockupDynamic} to spend the amount of assets.
        _handleTransfer(address(lockupDynamic), asset, transferAmount);

        // Create a stream for each element in the parameter array.
        streamIds = new uint256[](batchSize);
        for (i = 0; i < batchSize; ++i) {
            // Create the stream.
            streamIds[i] = lockupDynamic.createWithTimestamps(
                LockupDynamic.CreateWithTimestamps({
                    sender: batch[i].sender,
                    recipient: batch[i].recipient,
                    totalAmount: batch[i].totalAmount,
                    asset: asset,
                    cancelable: batch[i].cancelable,
                    transferable: batch[i].transferable,
                    startTime: batch[i].startTime,
                    segments: batch[i].segments,
                    broker: batch[i].broker
                })
            );
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  HELPER FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Helper function to approve a Sablier contract to spend funds from the batch. If the current allowance
    /// is insufficient, this function approves Sablier to spend the exact `amount`.
    /// The {SafeERC20.forceApprove} function is used to handle special ERC-20 assets (e.g. USDT) that require the
    /// current allowance to be zero before setting it to a non-zero value.
    function _approve(address sablierContract, IERC20 asset, uint256 amount) internal {
        uint256 allowance = asset.allowance({ owner: address(this), spender: sablierContract });
        if (allowance < amount) {
            asset.forceApprove({ spender: sablierContract, value: amount });
        }
    }

    /// @dev Helper function to transfer assets from the caller to the batch contract and approve the Sablier contract.
    function _handleTransfer(address sablierContract, IERC20 asset, uint256 amount) internal {
        // Transfer the assets to the batch contract.
        asset.safeTransferFrom({ from: msg.sender, to: address(this), value: amount });

        // Approve the Sablier contract to spend funds.
        _approve(sablierContract, asset, amount);
    }
}
