// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

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
    function createWithDurations(
        ISablierV2LockupLinear lockupLinear,
        IERC20 asset,
        Batch.CreateWithDurations[] calldata batch
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
        for (i = 0; i < batchSize;) {
            unchecked {
                transferAmount += batch[i].totalAmount;
                i += 1;
            }
        }

        // Transfers the assets to the batch and approves the Sablier contract to spend them.
        _handleTransfer(address(lockupLinear), asset, transferAmount);

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
                    totalAmount: batch[i].totalAmount,
                    transferable: batch[i].transferable
                })
            );

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
        }
    }

    /// @inheritdoc ISablierV2Batch
    function createWithRange(
        ISablierV2LockupLinear lockupLinear,
        IERC20 asset,
        Batch.CreateWithRange[] calldata batch
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
        for (i = 0; i < batchSize;) {
            unchecked {
                transferAmount += batch[i].totalAmount;
                i += 1;
            }
        }

        // Transfers the assets to the batch and approve the Sablier contract to spend them.
        _handleTransfer(address(lockupLinear), asset, transferAmount);

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
                    totalAmount: batch[i].totalAmount,
                    transferable: batch[i].transferable
                })
            );

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                             SABLIER-V2-LOCKUP-DYNAMIC
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2Batch
    function createWithDeltas(
        ISablierV2LockupDynamic lockupDynamic,
        IERC20 asset,
        Batch.CreateWithDeltas[] calldata batch
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
        for (i = 0; i < batchSize;) {
            unchecked {
                transferAmount += batch[i].totalAmount;
                i += 1;
            }
        }

        // Perform the ERC-20 transfer and approve {SablierV2LockupDynamic} to spend the amount of assets.
        _handleTransfer(address(lockupDynamic), asset, transferAmount);

        // Create a stream for each element in the parameter array.
        streamIds = new uint256[](batchSize);
        for (i = 0; i < batchSize;) {
            // Create the stream.
            streamIds[i] = lockupDynamic.createWithDeltas(
                LockupDynamic.CreateWithDeltas({
                    asset: asset,
                    broker: batch[i].broker,
                    cancelable: batch[i].cancelable,
                    recipient: batch[i].recipient,
                    segments: batch[i].segments,
                    sender: batch[i].sender,
                    totalAmount: batch[i].totalAmount,
                    transferable: batch[i].transferable
                })
            );

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
        }
    }

    /// @inheritdoc ISablierV2Batch
    function createWithMilestones(
        ISablierV2LockupDynamic lockupDynamic,
        IERC20 asset,
        Batch.CreateWithMilestones[] calldata batch
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
        for (i = 0; i < batchSize;) {
            unchecked {
                transferAmount += batch[i].totalAmount;
                i += 1;
            }
        }

        // Perform the ERC-20 transfer and approve {SablierV2LockupDynamic} to spend the amount of assets.
        _handleTransfer(address(lockupDynamic), asset, transferAmount);

        // Create a stream for each element in the parameter array.
        streamIds = new uint256[](batchSize);
        for (i = 0; i < batchSize;) {
            // Create the stream.
            streamIds[i] = lockupDynamic.createWithMilestones(
                LockupDynamic.CreateWithMilestones({
                    asset: asset,
                    broker: batch[i].broker,
                    cancelable: batch[i].cancelable,
                    recipient: batch[i].recipient,
                    segments: batch[i].segments,
                    sender: batch[i].sender,
                    startTime: batch[i].startTime,
                    totalAmount: batch[i].totalAmount,
                    transferable: batch[i].transferable
                })
            );

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
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
