// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <0.9.0;

import { UD2x18, ud2x18 } from "@prb/math/UD2x18.sol";
import { UD60x18, ZERO } from "@prb/math/UD60x18.sol";
import { Broker, Lockup, LockupLinear, LockupPro } from "@sablier/v2-core/types/DataTypes.sol";

import { CreateLinear, CreatePro } from "src/types/DataTypes.sol";

abstract contract Constants {
    /*//////////////////////////////////////////////////////////////////////////
                                  INTERNAL STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    struct Users {
        // Default admin of all Sablier V2 contracts.
        address payable admin;
        // Neutral user.
        address payable alice;
        // Default stream broker.
        address payable broker;
        // Malicious user.
        address payable eve;
        // Default stream recipient.
        address payable recipient;
        // Default stream sender.
        address payable sender;
    }

    Users internal users;

    /*//////////////////////////////////////////////////////////////////////////
                                  SIMPLE CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    uint128 internal constant DEFAULT_AMOUNT = 10_000e18;
    UD60x18 internal constant DEFAULT_BROKER_FEE = ZERO;
    uint128 internal constant DEFAULT_BROKER_FEE_AMOUNT = 0;
    UD60x18 internal constant DEFAULT_MAX_FEE = UD60x18.wrap(0.1e18); // 10%
    uint256 internal constant DEFAULT_MAX_SEGMENT_COUNT = 1_000;
    uint40 internal immutable DEFAULT_CLIFF_TIME;
    uint40 internal constant DEFAULT_CLIFF_DURATION = 2_500 seconds;
    uint40 internal immutable DEFAULT_END_TIME;
    uint40 internal immutable DEFAULT_START_TIME;
    uint40 internal constant DEFAULT_TIME_WARP = 2_600 seconds;
    uint128 internal constant DEFAULT_TOTAL_AMOUNT = 100_000e18;
    uint40 internal constant DEFAULT_TOTAL_DURATION = 10_000 seconds;
    uint128 internal constant DEFAULT_WITHDRAW_AMOUNT = 2_600e18;

    uint256 internal constant PARAMS_COUNT = 10;
    uint128 internal constant UINT128_MAX = type(uint128).max;
    uint256 internal constant UINT256_MAX = type(uint256).max;
    uint40 internal constant UINT40_MAX = type(uint40).max;

    /*//////////////////////////////////////////////////////////////////////////
                                 COMPLEX CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    Lockup.Amounts internal DEFAULT_LOCKUP_AMOUNTS = Lockup.Amounts({ deposit: DEFAULT_AMOUNT, withdrawn: 0 });
    LockupLinear.Durations internal DEFAULT_DURATIONS =
        LockupLinear.Durations({ cliff: DEFAULT_CLIFF_DURATION, total: DEFAULT_TOTAL_DURATION });
    LockupLinear.Range internal DEFAULT_LINEAR_RANGE;
    LockupPro.Range internal DEFAULT_PRO_RANGE;
    uint40[] internal DEFAULT_SEGMENT_DELTAS = [2_500 seconds, 7_500 seconds];

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor() {
        DEFAULT_START_TIME = uint40(block.timestamp);
        DEFAULT_CLIFF_TIME = DEFAULT_START_TIME + DEFAULT_CLIFF_DURATION;
        DEFAULT_END_TIME = DEFAULT_START_TIME + DEFAULT_TOTAL_DURATION;
        DEFAULT_LINEAR_RANGE = LockupLinear.Range({
            start: DEFAULT_START_TIME,
            cliff: DEFAULT_CLIFF_TIME,
            end: DEFAULT_END_TIME
        });
        DEFAULT_PRO_RANGE = LockupPro.Range({ start: DEFAULT_START_TIME, end: DEFAULT_END_TIME });
    }
}
