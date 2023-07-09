// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { LockupDynamic, LockupLinear } from "@sablier/v2-core/types/DataTypes.sol";

import { Batch } from "../../src/types/DataTypes.sol";

library BatchBuilder {
    /// @notice Generates an array containing `batchSize` copies of `sample`.
    function generateBatchFromSample(
        Batch.CreateWithDeltas memory sample,
        uint256 batchSize
    )
        internal
        pure
        returns (Batch.CreateWithDeltas[] memory batch)
    {
        batch = new Batch.CreateWithDeltas[](batchSize);
        unchecked {
            for (uint256 i = 0; i < batchSize; ++i) {
                batch[i] = sample;
            }
        }
    }

    /// @notice Turns the `params` into an array of `Batch.CreateWithDeltas` structs.
    function generateBatchFromParams(
        LockupDynamic.CreateWithDeltas memory params,
        uint256 batchSize
    )
        internal
        pure
        returns (Batch.CreateWithDeltas[] memory batch)
    {
        batch = new Batch.CreateWithDeltas[](batchSize);
        Batch.CreateWithDeltas memory sample = Batch.CreateWithDeltas({
            broker: params.broker,
            cancelable: params.cancelable,
            recipient: params.recipient,
            segments: params.segments,
            sender: params.sender,
            totalAmount: params.totalAmount
        });
        batch = generateBatchFromSample(sample, batchSize);
    }

    /// @notice Generates an array containing `batchSize` copies of `sample`.
    function generateBatchFromSample(
        Batch.CreateWithDurations memory sample,
        uint256 batchSize
    )
        internal
        pure
        returns (Batch.CreateWithDurations[] memory batch)
    {
        batch = new Batch.CreateWithDurations[](batchSize);
        unchecked {
            for (uint256 i = 0; i < batchSize; ++i) {
                batch[i] = sample;
            }
        }
    }

    /// @notice Turns the `params` into an array of `Batch.CreateWithDurations` structs.
    function generateBatchFromParams(
        LockupLinear.CreateWithDurations memory params,
        uint256 batchSize
    )
        internal
        pure
        returns (Batch.CreateWithDurations[] memory batch)
    {
        batch = new Batch.CreateWithDurations[](batchSize);
        Batch.CreateWithDurations memory sample = Batch.CreateWithDurations({
            broker: params.broker,
            cancelable: params.cancelable,
            durations: params.durations,
            recipient: params.recipient,
            sender: params.sender,
            totalAmount: params.totalAmount
        });
        batch = generateBatchFromSample(sample, batchSize);
    }

    /// @notice Generates an array containing `batchSize` copies of `sample`.
    function generateBatchFromSample(
        Batch.CreateWithMilestones memory sample,
        uint256 batchSize
    )
        internal
        pure
        returns (Batch.CreateWithMilestones[] memory batch)
    {
        batch = new Batch.CreateWithMilestones[](batchSize);
        unchecked {
            for (uint256 i = 0; i < batchSize; ++i) {
                batch[i] = sample;
            }
        }
    }

    /// @notice Turns the `params` into an array of `Batch.CreateWithMilestones` structs.
    function generateBatchFromParams(
        LockupDynamic.CreateWithMilestones memory params,
        uint256 batchSize
    )
        internal
        pure
        returns (Batch.CreateWithMilestones[] memory batch)
    {
        batch = new Batch.CreateWithMilestones[](batchSize);
        Batch.CreateWithMilestones memory sample = Batch.CreateWithMilestones({
            broker: params.broker,
            cancelable: params.cancelable,
            recipient: params.recipient,
            segments: params.segments,
            sender: params.sender,
            startTime: params.startTime,
            totalAmount: params.totalAmount
        });
        batch = generateBatchFromSample(sample, batchSize);
    }

    /// @notice Generates an array containing `batchSize` copies of `sample`.
    function generateBatchFromSample(
        Batch.CreateWithRange memory sample,
        uint256 batchSize
    )
        internal
        pure
        returns (Batch.CreateWithRange[] memory batch)
    {
        batch = new Batch.CreateWithRange[](batchSize);
        unchecked {
            for (uint256 i = 0; i < batchSize; ++i) {
                batch[i] = sample;
            }
        }
    }

    /// @notice Turns the `params` into an array of `Batch.CreateWithRange` structs.
    function generateBatchFromParams(
        LockupLinear.CreateWithRange memory params,
        uint256 batchSize
    )
        internal
        pure
        returns (Batch.CreateWithRange[] memory batch)
    {
        batch = new Batch.CreateWithRange[](batchSize);
        Batch.CreateWithRange memory sample = Batch.CreateWithRange({
            broker: params.broker,
            cancelable: params.cancelable,
            range: params.range,
            recipient: params.recipient,
            sender: params.sender,
            totalAmount: params.totalAmount
        });
        batch = generateBatchFromSample(sample, batchSize);
    }
}
