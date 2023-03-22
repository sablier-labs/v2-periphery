// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { UD2x18, ud2x18 } from "@prb/math/UD2x18.sol";
import { UD60x18, ZERO } from "@prb/math/UD60x18.sol";
import { Broker, LockupLinear, LockupDynamic } from "@sablier/v2-core/types/DataTypes.sol";

abstract contract Constants {
    /*//////////////////////////////////////////////////////////////////////////
                                  SIMPLE CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    uint128 internal constant DEFAULT_AMOUNT = 10_000e18;
    UD60x18 internal constant DEFAULT_BROKER_FEE = ZERO;
    uint128 internal constant DEFAULT_BROKER_FEE_AMOUNT = 0;
    UD60x18 internal constant DEFAULT_MAX_FEE = UD60x18.wrap(0.1e18); // 10%
    uint256 internal constant DEFAULT_MAX_SEGMENT_COUNT = 1000;
    uint40 internal immutable DEFAULT_CLIFF_TIME;
    uint40 internal constant DEFAULT_CLIFF_DURATION = 2500 seconds;
    uint40 internal immutable DEFAULT_END_TIME;
    uint48 internal immutable DEFAULT_PERMIT2_EXPIRATION;
    uint48 internal constant DEFAULT_PERMIT2_NONCE = 0;
    uint256 internal immutable DEFAULT_PERMIT2_SIG_DEADLINE;
    uint40 internal immutable DEFAULT_START_TIME;
    uint40 internal constant DEFAULT_TIME_WARP = 2600 seconds;
    uint128 internal constant DEFAULT_TOTAL_AMOUNT = 100_000e18;
    uint40 internal constant DEFAULT_TOTAL_DURATION = 10_000 seconds;
    uint128 internal constant DEFAULT_WITHDRAW_AMOUNT = 2600e18;

    uint256 internal constant PARAMS_COUNT = 10;
    uint128 internal constant UINT128_MAX = type(uint128).max;
    uint160 internal constant UINT160_MAX = type(uint160).max;
    uint256 internal constant UINT256_MAX = type(uint256).max;
    uint40 internal constant UINT40_MAX = type(uint40).max;
    uint48 internal constant UINT48_MAX = type(uint48).max;

    bytes32 internal DOMAIN_SEPARATOR;
    // forgefmt: disable-next-line
    bytes32 internal constant PERMIT_DETAILS_TYPEHASH = keccak256("PermitDetails(address token,uint160 amount,uint48 expiration,uint48 nonce)");
    // forgefmt: disable-next-line
    bytes32 internal constant PERMIT_SINGLE_TYPEHASH = keccak256("PermitSingle(PermitDetails details,address spender,uint256 sigDeadline)PermitDetails(address token,uint160 amount,uint48 expiration,uint48 nonce)");

    /*//////////////////////////////////////////////////////////////////////////
                                 COMPLEX CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    LockupLinear.Durations internal DEFAULT_DURATIONS =
        LockupLinear.Durations({ cliff: DEFAULT_CLIFF_DURATION, total: DEFAULT_TOTAL_DURATION });
    LockupLinear.Range internal DEFAULT_LINEAR_RANGE;
    LockupDynamic.Range internal DEFAULT_DYNAMIC_RANGE;
    uint256[] internal DEFAULT_STREAM_IDS = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor() {
        DEFAULT_START_TIME = uint40(block.timestamp);
        DEFAULT_CLIFF_TIME = DEFAULT_START_TIME + DEFAULT_CLIFF_DURATION;
        DEFAULT_END_TIME = DEFAULT_START_TIME + DEFAULT_TOTAL_DURATION;
        DEFAULT_PERMIT2_EXPIRATION = UINT48_MAX;
        DEFAULT_PERMIT2_SIG_DEADLINE = uint256(DEFAULT_START_TIME + 100);
        DEFAULT_LINEAR_RANGE =
            LockupLinear.Range({ start: DEFAULT_START_TIME, cliff: DEFAULT_CLIFF_TIME, end: DEFAULT_END_TIME });
        DEFAULT_DYNAMIC_RANGE = LockupDynamic.Range({ start: DEFAULT_START_TIME, end: DEFAULT_END_TIME });
    }
}
