// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { LockupDynamic, LockupLinear } from "@sablier/v2-core/types/DataTypes.sol";

import { Batch, Permit2Params } from "../../src/types/DataTypes.sol";

/// @notice Utility for converting {Batch} params to {LockupDynamic} and {LockupLinear} params.
library ParamsBuilder {
    function createWithDeltas(
        Batch.CreateWithDeltas memory batchSingle,
        IERC20 asset
    )
        internal
        pure
        returns (LockupDynamic.CreateWithDeltas memory params)
    {
        params = LockupDynamic.CreateWithDeltas({
            asset: asset,
            broker: batchSingle.broker,
            cancelable: batchSingle.cancelable,
            recipient: batchSingle.recipient,
            segments: batchSingle.segments,
            sender: batchSingle.sender,
            totalAmount: batchSingle.totalAmount
        });
    }

    function createWithDurations(
        Batch.CreateWithDurations memory batchSingle,
        IERC20 asset
    )
        internal
        pure
        returns (LockupLinear.CreateWithDurations memory params)
    {
        params = LockupLinear.CreateWithDurations({
            asset: asset,
            broker: batchSingle.broker,
            cancelable: batchSingle.cancelable,
            durations: batchSingle.durations,
            recipient: batchSingle.recipient,
            sender: batchSingle.sender,
            totalAmount: batchSingle.totalAmount
        });
    }

    function createWithMilestones(
        Batch.CreateWithMilestones memory batchSingle,
        IERC20 asset
    )
        internal
        pure
        returns (LockupDynamic.CreateWithMilestones memory params)
    {
        params = LockupDynamic.CreateWithMilestones({
            asset: asset,
            broker: batchSingle.broker,
            cancelable: batchSingle.cancelable,
            recipient: batchSingle.recipient,
            segments: batchSingle.segments,
            sender: batchSingle.sender,
            startTime: batchSingle.startTime,
            totalAmount: batchSingle.totalAmount
        });
    }

    function createWithRange(
        Batch.CreateWithRange memory batchSingle,
        IERC20 asset
    )
        internal
        pure
        returns (LockupLinear.CreateWithRange memory params)
    {
        params = LockupLinear.CreateWithRange({
            asset: asset,
            broker: batchSingle.broker,
            cancelable: batchSingle.cancelable,
            recipient: batchSingle.recipient,
            sender: batchSingle.sender,
            range: batchSingle.range,
            totalAmount: batchSingle.totalAmount
        });
    }
}
