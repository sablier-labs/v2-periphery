// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { ISablierV2Lockup } from "@sablier/v2-core/src/interfaces/ISablierV2Lockup.sol";
import { Broker, LockupDynamic, LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

library Batch {
    /// @notice A struct encapsulating the lockup contract's address and the stream ids to cancel.
    struct CancelMultiple {
        ISablierV2Lockup lockup;
        uint256[] streamIds;
    }

    /// @notice A struct encapsulating all parameters of {SablierV2LockupDynamic.createWithDelta} except for the asset.
    struct CreateWithDeltas {
        address sender;
        address recipient;
        uint128 totalAmount;
        bool cancelable;
        bool transferable;
        LockupDynamic.SegmentWithDelta[] segments;
        Broker broker;
    }

    /// @notice A struct encapsulating all parameters of {SablierV2LockupLinear.createWithDurations} except for the
    /// asset.
    struct CreateWithDurations {
        address sender;
        address recipient;
        uint128 totalAmount;
        bool cancelable;
        bool transferable;
        LockupLinear.Durations durations;
        Broker broker;
    }

    /// @notice A struct encapsulating all parameters of {SablierV2LockupDynamic.createWithMilestones} except for the
    /// asset.
    struct CreateWithMilestones {
        address sender;
        address recipient;
        uint128 totalAmount;
        uint40 startTime;
        bool cancelable;
        bool transferable;
        LockupDynamic.Segment[] segments;
        Broker broker;
    }

    /// @notice A struct encapsulating all parameters of {SablierV2LockupLinear.createWithRange} except for the asset.
    struct CreateWithRange {
        address sender;
        address recipient;
        uint128 totalAmount;
        bool cancelable;
        bool transferable;
        Broker broker;
        LockupLinear.Range range;
    }
}
