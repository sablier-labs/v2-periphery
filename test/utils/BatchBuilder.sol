// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { LockupDynamic, LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { Batch } from "../../src/types/DataTypes.sol";

library BatchBuilder {
    /// @notice Generates an array containing `batchSize` copies of `batchSingle`.
    function fillBatch(
        Batch.CreateWithDeltas memory batchSingle,
        uint256 batchSize
    )
        internal
        pure
        returns (Batch.CreateWithDeltas[] memory batch)
    {
        batch = new Batch.CreateWithDeltas[](batchSize);
        unchecked {
            for (uint256 i = 0; i < batchSize; ++i) {
                batch[i] = batchSingle;
            }
        }
    }

    /// @notice Turns the `params` into an array of `Batch.CreateWithDeltas` structs.
    function fillBatch(
        LockupDynamic.CreateWithDeltas memory params,
        uint256 batchSize
    )
        internal
        pure
        returns (Batch.CreateWithDeltas[] memory batch)
    {
        batch = new Batch.CreateWithDeltas[](batchSize);
        Batch.CreateWithDeltas memory batchSingle = Batch.CreateWithDeltas({
            broker: params.broker,
            cancelable: params.cancelable,
            recipient: params.recipient,
            segments: params.segments,
            sender: params.sender,
            totalAmount: params.totalAmount,
            transferable: params.transferable
        });
        batch = fillBatch(batchSingle, batchSize);
    }

    /// @notice Generates an array containing `batchSize` copies of `batchSingle`.
    function fillBatch(
        Batch.CreateWithDurations memory batchSingle,
        uint256 batchSize
    )
        internal
        pure
        returns (Batch.CreateWithDurations[] memory batch)
    {
        batch = new Batch.CreateWithDurations[](batchSize);
        unchecked {
            for (uint256 i = 0; i < batchSize; ++i) {
                batch[i] = batchSingle;
            }
        }
    }

    /// @notice Turns the `params` into an array of `Batch.CreateWithDurations` structs.
    function fillBatch(
        LockupLinear.CreateWithDurations memory params,
        uint256 batchSize
    )
        internal
        pure
        returns (Batch.CreateWithDurations[] memory batch)
    {
        batch = new Batch.CreateWithDurations[](batchSize);
        Batch.CreateWithDurations memory batchSingle = Batch.CreateWithDurations({
            broker: params.broker,
            cancelable: params.cancelable,
            durations: params.durations,
            recipient: params.recipient,
            sender: params.sender,
            totalAmount: params.totalAmount,
            transferable: params.transferable
        });
        batch = fillBatch(batchSingle, batchSize);
    }

    /// @notice Generates an array containing `batchSize` copies of `batchSingle`.
    function fillBatch(
        Batch.CreateWithMilestones memory batchSingle,
        uint256 batchSize
    )
        internal
        pure
        returns (Batch.CreateWithMilestones[] memory batch)
    {
        batch = new Batch.CreateWithMilestones[](batchSize);
        unchecked {
            for (uint256 i = 0; i < batchSize; ++i) {
                batch[i] = batchSingle;
            }
        }
    }

    /// @notice Turns the `params` into an array of `Batch.CreateWithMilestones` structs.
    function fillBatch(
        LockupDynamic.CreateWithMilestones memory params,
        uint256 batchSize
    )
        internal
        pure
        returns (Batch.CreateWithMilestones[] memory batch)
    {
        batch = new Batch.CreateWithMilestones[](batchSize);
        Batch.CreateWithMilestones memory batchSingle = Batch.CreateWithMilestones({
            broker: params.broker,
            cancelable: params.cancelable,
            recipient: params.recipient,
            segments: params.segments,
            sender: params.sender,
            startTime: params.startTime,
            totalAmount: params.totalAmount,
            transferable: params.transferable
        });
        batch = fillBatch(batchSingle, batchSize);
    }

    /// @notice Generates an array containing `batchSize` copies of `batchSingle`.
    function fillBatch(
        Batch.CreateWithRange memory batchSingle,
        uint256 batchSize
    )
        internal
        pure
        returns (Batch.CreateWithRange[] memory batch)
    {
        batch = new Batch.CreateWithRange[](batchSize);
        unchecked {
            for (uint256 i = 0; i < batchSize; ++i) {
                batch[i] = batchSingle;
            }
        }
    }

    /// @notice Turns the `params` into an array of `Batch.CreateWithRange` structs.
    function fillBatch(
        LockupLinear.CreateWithRange memory params,
        uint256 batchSize
    )
        internal
        pure
        returns (Batch.CreateWithRange[] memory batch)
    {
        batch = new Batch.CreateWithRange[](batchSize);
        Batch.CreateWithRange memory batchSingle = Batch.CreateWithRange({
            broker: params.broker,
            cancelable: params.cancelable,
            range: params.range,
            recipient: params.recipient,
            sender: params.sender,
            totalAmount: params.totalAmount,
            transferable: params.transferable
        });
        batch = fillBatch(batchSingle, batchSize);
    }
}
