// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.13;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";

import { Broker, LockupPro, LockupLinear } from "@sablier/v2-core/types/DataTypes.sol";

library CreateLinear {
    struct DurationsParams {
        address sender;
        address recipient;
        uint128 amount;
        bool cancelable;
        LockupLinear.Durations durations;
        Broker broker;
    }
    struct RangeParams {
        address sender;
        address recipient;
        uint128 amount;
        bool cancelable;
        LockupLinear.Range range;
        Broker broker;
    }
}

library CreatePro {
    struct DeltasParams {
        address sender;
        address recipient;
        uint128 amount;
        LockupPro.Segment[] segments;
        bool cancelable;
        uint40[] deltas;
        Broker broker;
    }
    struct MilestonesParams {
        address sender;
        address recipient;
        uint128 amount;
        LockupPro.Segment[] segments;
        bool cancelable;
        uint40 startTime;
        Broker broker;
    }
}
