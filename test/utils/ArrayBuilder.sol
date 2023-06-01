// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { Batch, Permit2Params } from "../../src/types/DataTypes.sol";

library ArrayBuilder {
    /// @notice Generates an array of `batchSingle` with the specified `batchSize`.
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

    /// @notice Generates an array of `batchSingle` with the specified `batchSize`.
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

    /// @notice Generates an array of `batchSingle` with the specified `batchSize`.
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

    /// @notice Generates an array of `batchSingle` with the specified `batchSize`.
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

    /// @notice Generates an ordered array of integers which starts at `firstStreamId` and ends at `firstStreamId +
    /// batchSize - 1`.
    function fillStreamIds(
        uint256 firstStreamId,
        uint256 batchSize
    )
        internal
        pure
        returns (uint256[] memory streamIds)
    {
        streamIds = new uint256[](batchSize);
        unchecked {
            for (uint256 i = 0; i < batchSize; ++i) {
                streamIds[i] = firstStreamId + i;
            }
        }
    }
}
