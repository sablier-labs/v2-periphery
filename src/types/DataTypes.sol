// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.13;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";

import { Broker } from "@sablier/v2-core/types/DataTypes.sol";
import { LockupLinear } from "@sablier/v2-core/types/DataTypes.sol";
import { LockupPro } from "@sablier/v2-core/types/DataTypes.sol";

library CreateLinear {
    struct RangeParams {
        address sender;
        address recipient;
        uint128 grossDepositAmount;
        bool cancelable;
        LockupLinear.Range range;
        Broker broker;
    }
}

library CreatePro {
    struct MilestoneParams {
        address sender;
        address recipient;
        uint128 grossDepositAmount;
        LockupPro.Segment[] segments;
        bool cancelable;
        uint40 startTime;
        Broker broker;
    }
}
