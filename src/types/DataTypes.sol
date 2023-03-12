// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.19;

import { IAllowanceTransfer } from "@permit2/interfaces/IAllowanceTransfer.sol";
import { ISablierV2Lockup } from "@sablier/v2-core/interfaces/ISablierV2Lockup.sol";
import { Broker, LockupLinear, LockupPro } from "@sablier/v2-core/types/DataTypes.sol";

struct Permit2Params {
    IAllowanceTransfer permit2;
    uint48 expiration;
    uint256 sigDeadline;
    bytes signature;
}

library Batch {
    /// @notice Simple struct that encapsulates (i) the lockup contract and (ii) the stream id.
    struct Cancel {
        ISablierV2Lockup lockup;
        uint256 streamId;
    }

    /// @notice Simple struct that encapsulates (i) the lockup contract and (ii) the stream ids.
    struct CancelMultiple {
        ISablierV2Lockup lockup;
        uint256[] streamIds;
    }

    /// @notice Struct that partially encapsulates the {SablierV2LockupPro-createWithDelta} function parameters.
    struct CreateWithDeltas {
        uint128 amount;
        Broker broker;
        bool cancelable;
        address recipient;
        LockupPro.SegmentWithDelta[] segments;
        address sender;
    }

    /// @notice Struct that partially encapsulates the {SablierV2LockupLinear-createWithDurations} function parameters.
    struct CreateWithDurations {
        uint128 amount;
        Broker broker;
        bool cancelable;
        LockupLinear.Durations durations;
        address recipient;
        address sender;
    }

    /// @notice Struct that partially encapsulates the {SablierV2LockupPro-createWithMilestones} function parameters.
    struct CreateWithMilestones {
        uint128 amount;
        Broker broker;
        bool cancelable;
        address recipient;
        LockupPro.Segment[] segments;
        address sender;
        uint40 startTime;
    }

    /// @notice Struct that partially encapsulates the {SablierV2LockupLinear-createWithRange} function parameters.
    struct CreateWithRange {
        uint128 amount;
        Broker broker;
        bool cancelable;
        LockupLinear.Range range;
        address recipient;
        address sender;
    }
}
