// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { ISablierV2Lockup } from "@sablier/v2-core/interfaces/ISablierV2Lockup.sol";
import { Broker, LockupDynamic, LockupLinear } from "@sablier/v2-core/types/DataTypes.sol";

library Batch {
    /// @notice Struct encapsulating the lockup contract's address and the stream ids to cancel.
    struct CancelMultiple {
        ISablierV2Lockup lockup;
        uint256[] streamIds;
    }

    /// @notice Struct encapsulating all parameters of {SablierV2LockupDynamic.createWithDelta} except for the asset.
    struct CreateWithDeltas {
        Broker broker;
        address recipient;
        LockupDynamic.SegmentWithDelta[] segments;
        address sender;
        uint128 totalAmount;
        bool cancelable;
    }

    /// @notice Struct encapsulating all parameters of {SablierV2LockupLinear.createWithDurations} except for the asset.
    struct CreateWithDurations {
        Broker broker;
        LockupLinear.Durations durations;
        address recipient;
        address sender;
        uint128 totalAmount;
        bool cancelable;
    }

    /// @notice Struct encapsulating all parameters of {SablierV2LockupDynamic.createWithMilestones} except for the
    /// asset.
    struct CreateWithMilestones {
        Broker broker;
        address recipient;
        LockupDynamic.Segment[] segments;
        address sender;
        uint128 totalAmount;
        uint40 startTime;
        bool cancelable;
    }

    /// @notice Struct encapsulating all parameters of {SablierV2LockupLinear.createWithRange} except for the asset.
    struct CreateWithRange {
        Broker broker;
        LockupLinear.Range range;
        address recipient;
        address sender;
        uint128 totalAmount;
        bool cancelable;
    }
}

/// @notice Struct encapsulating the user parameters needed for Permit2.
/// @dev See the full documentation at https://github.com/Uniswap/permit2.
struct Permit2Params {
    uint48 expiration;
    uint256 sigDeadline;
    bytes signature;
}
