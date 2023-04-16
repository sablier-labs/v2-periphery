// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IAllowanceTransfer } from "permit2/interfaces/IAllowanceTransfer.sol";
import { ISablierV2Lockup } from "@sablier/v2-core/interfaces/ISablierV2Lockup.sol";
import { Broker, LockupLinear, LockupDynamic } from "@sablier/v2-core/types/DataTypes.sol";

library Batch {
    /// @notice Struct encapsulating the lockup contract's address and the stream ids to cancel.
    struct CancelMultiple {
        ISablierV2Lockup lockup;
        uint256[] streamIds;
    }

    /// @notice Struct encapsulating a subset of the parameters of {SablierV2LockupDynamic.createWithDelta}.
    struct CreateWithDeltas {
        uint128 amount;
        Broker broker;
        bool cancelable;
        address recipient;
        LockupDynamic.SegmentWithDelta[] segments;
        address sender;
    }

    /// @notice Struct encapsulating a subset of the parameters of {SablierV2LockupLinear.createWithDurations}.
    struct CreateWithDurations {
        uint128 amount;
        Broker broker;
        bool cancelable;
        LockupLinear.Durations durations;
        address recipient;
        address sender;
    }

    /// @notice Struct encapsulating a subset of the parameters of {SablierV2LockupDynamic.createWithMilestones}.
    struct CreateWithMilestones {
        uint128 amount;
        Broker broker;
        bool cancelable;
        address recipient;
        LockupDynamic.Segment[] segments;
        address sender;
        uint40 startTime;
    }

    /// @notice Struct encapsulating a subset of the parameters of {SablierV2LockupLinear.createWithRange}.
    struct CreateWithRange {
        uint128 amount;
        Broker broker;
        bool cancelable;
        LockupLinear.Range range;
        address recipient;
        address sender;
    }
}

/// @notice Struct encapsulating the user parameters needed for Permit2.
struct Permit2Params {
    uint48 expiration;
    IAllowanceTransfer permit2;
    uint256 sigDeadline;
    bytes signature;
}
