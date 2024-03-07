// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { LockupDynamic, LockupLinear, LockupTranched } from "@sablier/v2-core/src/types/DataTypes.sol";

import { Batch } from "../../src/types/DataTypes.sol";

library BatchBuilder {
    /// @notice Generates an array containing `batchSize` copies of `batchSingle`.
    function fillBatch(
        Batch.CreateWithDurationsLD memory batchSingle,
        uint256 batchSize
    )
        internal
        pure
        returns (Batch.CreateWithDurationsLD[] memory batch)
    {
        batch = new Batch.CreateWithDurationsLD[](batchSize);
        for (uint256 i = 0; i < batchSize; ++i) {
            batch[i] = batchSingle;
        }
    }

    /// @notice Turns the `params` into an array of `Batch.CreateWithDurationsLD` structs.
    function fillBatch(
        LockupDynamic.CreateWithDurations memory params,
        uint256 batchSize
    )
        internal
        pure
        returns (Batch.CreateWithDurationsLD[] memory batch)
    {
        batch = new Batch.CreateWithDurationsLD[](batchSize);
        Batch.CreateWithDurationsLD memory batchSingle = Batch.CreateWithDurationsLD({
            sender: params.sender,
            recipient: params.recipient,
            totalAmount: params.totalAmount,
            cancelable: params.cancelable,
            transferable: params.transferable,
            segments: params.segments,
            broker: params.broker
        });
        batch = fillBatch(batchSingle, batchSize);
    }

    /// @notice Generates an array containing `batchSize` copies of `batchSingle`.
    function fillBatch(
        Batch.CreateWithDurationsLL memory batchSingle,
        uint256 batchSize
    )
        internal
        pure
        returns (Batch.CreateWithDurationsLL[] memory batch)
    {
        batch = new Batch.CreateWithDurationsLL[](batchSize);
        for (uint256 i = 0; i < batchSize; ++i) {
            batch[i] = batchSingle;
        }
    }

    /// @notice Turns the `params` into an array of `Batch.CreateWithDurationsLL` structs.
    function fillBatch(
        LockupLinear.CreateWithDurations memory params,
        uint256 batchSize
    )
        internal
        pure
        returns (Batch.CreateWithDurationsLL[] memory batch)
    {
        batch = new Batch.CreateWithDurationsLL[](batchSize);
        Batch.CreateWithDurationsLL memory batchSingle = Batch.CreateWithDurationsLL({
            sender: params.sender,
            recipient: params.recipient,
            totalAmount: params.totalAmount,
            cancelable: params.cancelable,
            transferable: params.transferable,
            durations: params.durations,
            broker: params.broker
        });
        batch = fillBatch(batchSingle, batchSize);
    }

    /// @notice Generates an array containing `batchSize` copies of `batchSingle`.
    function fillBatch(
        Batch.CreateWithDurationsLT memory batchSingle,
        uint256 batchSize
    )
        internal
        pure
        returns (Batch.CreateWithDurationsLT[] memory batch)
    {
        batch = new Batch.CreateWithDurationsLT[](batchSize);
        for (uint256 i = 0; i < batchSize; ++i) {
            batch[i] = batchSingle;
        }
    }

    /// @notice Turns the `params` into an array of `Batch.CreateWithDurationsLT` structs.
    function fillBatch(
        LockupTranched.CreateWithDurations memory params,
        uint256 batchSize
    )
        internal
        pure
        returns (Batch.CreateWithDurationsLT[] memory batch)
    {
        batch = new Batch.CreateWithDurationsLT[](batchSize);
        Batch.CreateWithDurationsLT memory batchSingle = Batch.CreateWithDurationsLT({
            sender: params.sender,
            recipient: params.recipient,
            totalAmount: params.totalAmount,
            cancelable: params.cancelable,
            transferable: params.transferable,
            tranches: params.tranches,
            broker: params.broker
        });
        batch = fillBatch(batchSingle, batchSize);
    }

    /// @notice Generates an array containing `batchSize` copies of `batchSingle`.
    function fillBatch(
        Batch.CreateWithTimestampsLD memory batchSingle,
        uint256 batchSize
    )
        internal
        pure
        returns (Batch.CreateWithTimestampsLD[] memory batch)
    {
        batch = new Batch.CreateWithTimestampsLD[](batchSize);
        for (uint256 i = 0; i < batchSize; ++i) {
            batch[i] = batchSingle;
        }
    }

    /// @notice Turns the `params` into an array of `Batch.CreateWithTimestampsLDs` structs.
    function fillBatch(
        LockupDynamic.CreateWithTimestamps memory params,
        uint256 batchSize
    )
        internal
        pure
        returns (Batch.CreateWithTimestampsLD[] memory batch)
    {
        batch = new Batch.CreateWithTimestampsLD[](batchSize);
        Batch.CreateWithTimestampsLD memory batchSingle = Batch.CreateWithTimestampsLD({
            sender: params.sender,
            recipient: params.recipient,
            totalAmount: params.totalAmount,
            cancelable: params.cancelable,
            transferable: params.transferable,
            startTime: params.startTime,
            segments: params.segments,
            broker: params.broker
        });
        batch = fillBatch(batchSingle, batchSize);
    }

    /// @notice Generates an array containing `batchSize` copies of `batchSingle`.
    function fillBatch(
        Batch.CreateWithTimestampsLL memory batchSingle,
        uint256 batchSize
    )
        internal
        pure
        returns (Batch.CreateWithTimestampsLL[] memory batch)
    {
        batch = new Batch.CreateWithTimestampsLL[](batchSize);
        for (uint256 i = 0; i < batchSize; ++i) {
            batch[i] = batchSingle;
        }
    }

    /// @notice Turns the `params` into an array of `Batch.CreateWithTimestampsLL` structs.
    function fillBatch(
        LockupLinear.CreateWithTimestamps memory params,
        uint256 batchSize
    )
        internal
        pure
        returns (Batch.CreateWithTimestampsLL[] memory batch)
    {
        batch = new Batch.CreateWithTimestampsLL[](batchSize);
        Batch.CreateWithTimestampsLL memory batchSingle = Batch.CreateWithTimestampsLL({
            sender: params.sender,
            recipient: params.recipient,
            totalAmount: params.totalAmount,
            cancelable: params.cancelable,
            transferable: params.transferable,
            range: params.range,
            broker: params.broker
        });
        batch = fillBatch(batchSingle, batchSize);
    }

    /// @notice Generates an array containing `batchSize` copies of `batchSingle`.
    function fillBatch(
        Batch.CreateWithTimestampsLT memory batchSingle,
        uint256 batchSize
    )
        internal
        pure
        returns (Batch.CreateWithTimestampsLT[] memory batch)
    {
        batch = new Batch.CreateWithTimestampsLT[](batchSize);
        for (uint256 i = 0; i < batchSize; ++i) {
            batch[i] = batchSingle;
        }
    }

    /// @notice Turns the `params` into an array of `Batch.CreateWithTimestampsLT` structs.
    function fillBatch(
        LockupTranched.CreateWithTimestamps memory params,
        uint256 batchSize
    )
        internal
        pure
        returns (Batch.CreateWithTimestampsLT[] memory batch)
    {
        batch = new Batch.CreateWithTimestampsLT[](batchSize);
        Batch.CreateWithTimestampsLT memory batchSingle = Batch.CreateWithTimestampsLT({
            sender: params.sender,
            recipient: params.recipient,
            totalAmount: params.totalAmount,
            cancelable: params.cancelable,
            transferable: params.transferable,
            startTime: params.startTime,
            tranches: params.tranches,
            broker: params.broker
        });
        batch = fillBatch(batchSingle, batchSize);
    }
}
