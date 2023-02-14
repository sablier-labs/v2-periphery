// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.18;

import { Broker, LockupPro, LockupLinear } from "@sablier/v2-core/types/DataTypes.sol";

library CreateLinear {
    struct DurationsParams {
        uint128 amount;
        Broker broker;
        bool cancelable;
        LockupLinear.Durations durations;
        address recipient;
        address sender;
    }

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
    struct DeltasParams {
        uint128 amount;
        Broker broker;
        bool cancelable;
        uint40[] deltas;
        address recipient;
        LockupPro.Segment[] segments;
        address sender;
    }

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
