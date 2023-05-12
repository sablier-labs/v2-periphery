// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { ISablierV2Lockup } from "@sablier/v2-core/interfaces/ISablierV2Lockup.sol";
import { Broker, LockupDynamic, LockupLinear } from "@sablier/v2-core/types/DataTypes.sol";

library Batch {
    /// @notice A struct encapsulating the lockup contract's address and the stream ids to cancel.
    struct CancelMultiple {
        ISablierV2Lockup lockup;
        uint256[] streamIds;
    }

    /// @notice A struct encapsulating all parameters of {SablierV2LockupDynamic.createWithDelta} except for the asset.
    struct CreateWithDeltas {
        address sender;
        bool cancelable;
        address recipient;
        uint128 totalAmount;
        Broker broker;
        LockupDynamic.SegmentWithDelta[] segments;
    }

    /// @notice A struct encapsulating all parameters of {SablierV2LockupLinear.createWithDurations} except for the
    /// asset.
    struct CreateWithDurations {
        address sender;
        address recipient;
        uint128 totalAmount;
        bool cancelable;
        LockupLinear.Durations durations;
        Broker broker;
    }

    /// @notice A struct encapsulating all parameters of {SablierV2LockupDynamic.createWithMilestones} except for the
    /// asset.
    struct CreateWithMilestones {
        address sender;
        uint40 startTime;
        bool cancelable;
        address recipient;
        uint128 totalAmount;
        Broker broker;
        LockupDynamic.Segment[] segments;
    }

    /// @notice A struct encapsulating all parameters of {SablierV2LockupLinear.createWithRange} except for the asset.
    struct CreateWithRange {
        address sender;
        address recipient;
        uint128 totalAmount;
        bool cancelable;
        LockupLinear.Range range;
        Broker broker;
    }
}

/// @notice A struct encapsulating the parameters needed for Permit2, most importantly the signature.
/// @dev See the full documentation at https://github.com/Uniswap/permit2.
struct Permit2Params {
    uint48 expiration;
    uint256 sigDeadline;
    bytes signature;
}
