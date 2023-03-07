// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.19;

import { Broker, LockupLinear, LockupPro } from "@sablier/v2-core/types/DataTypes.sol";
import { IAllowanceTransfer } from "@permit2/interfaces/IAllowanceTransfer.sol";

struct Permit2Params {
    IAllowanceTransfer permit2;
    uint48 expiration;
    uint256 sigDeadline;
    bytes signature;
}

library CreateLinear {
    /// @notice Struct that partially encapsulates the {SablierV2LockupLinear-createWithDurations} function parameters.
    struct DurationsParams {
        uint128 amount;
        Broker broker;
        bool cancelable;
        LockupLinear.Durations durations;
        address recipient;
        address sender;
    }

    /// @notice Struct that partially encapsulates the {SablierV2LockupLinear-createWithRange} function parameters.
    struct RangeParams {
        uint128 amount;
        Broker broker;
        bool cancelable;
        LockupLinear.Range range;
        address recipient;
        address sender;
    }
}

library CreatePro {
    /// @notice Struct that partially encapsulates the {SablierV2LockupPro-createWithDelta} function parameters.
    struct DeltasParams {
        uint128 amount;
        Broker broker;
        bool cancelable;
        address recipient;
        LockupPro.SegmentWithDelta[] segments;
        address sender;
    }

    /// @notice Struct that partially encapsulates the {SablierV2LockupPro-createWithMilestones} function parameters.
    struct MilestonesParams {
        uint128 amount;
        Broker broker;
        bool cancelable;
        address recipient;
        LockupPro.Segment[] segments;
        address sender;
        uint40 startTime;
    }
}
