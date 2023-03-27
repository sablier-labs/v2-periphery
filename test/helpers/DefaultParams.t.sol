// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { IAllowanceTransfer } from "@permit2/interfaces/IAllowanceTransfer.sol";
import { UD2x18, ud2x18 } from "@prb/math/UD2x18.sol";
import { UD60x18, ZERO } from "@prb/math/UD60x18.sol";
import { Broker, Lockup, LockupLinear, LockupDynamic } from "@sablier/v2-core/types/DataTypes.sol";

import { Batch, Permit2Params } from "src/types/DataTypes.sol";

library DefaultParams {
    /*//////////////////////////////////////////////////////////////////////////
                                      STRUCTS
    //////////////////////////////////////////////////////////////////////////*/

    struct PrivateKeys {
        uint256 admin;
        uint256 broker;
        uint256 recipient;
        uint256 sender;
    }

    struct Users {
        address payable admin;
        address payable broker;
        address payable recipient;
        address payable sender;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    uint128 internal constant UINT128_MAX = type(uint128).max;
    uint160 internal constant UINT160_MAX = type(uint160).max;
    uint256 internal constant UINT256_MAX = type(uint256).max;
    uint48 internal constant UINT48_MAX = type(uint48).max;

    UD60x18 internal constant MAX_FEE = UD60x18.wrap(0.1e18); // 10%
    uint256 internal constant MAX_SEGMENT_COUNT = 1000;

    uint40 internal constant CLIFF_DURATION = 2500 seconds;
    uint40 internal constant TOTAL_DURATION = 10_000 seconds;
    uint40 internal constant TIME_WARP = 2600 seconds;

    uint40 internal constant START_TIME = 1;
    uint40 internal constant CLIFF_TIME = START_TIME + CLIFF_DURATION;
    uint40 internal constant END_TIME = START_TIME + TOTAL_DURATION;

    uint128 internal constant AMOUNT = 10_000e18;
    UD60x18 internal constant BROKER_FEE = ZERO;
    uint128 internal constant BROKER_FEE_AMOUNT = 0;
    uint256 internal constant ETHER_AMOUNT = 10_000 ether;
    uint128 internal constant TOTAL_AMOUNT = 100_000e18;
    uint128 internal constant WITHDRAW_AMOUNT = 2600e18;

    uint256 internal constant BATCH_COUNT = 10;

    /*//////////////////////////////////////////////////////////////////////////
                                      PERMIT2
    //////////////////////////////////////////////////////////////////////////*/

    uint48 internal constant PERMIT2_NONCE = 0;
    uint48 internal constant PERMIT2_EXPIRATION = UINT48_MAX;
    uint256 internal constant PERMIT2_SIG_DEADLINE = 100;

    function permitDetails(
        address asset,
        uint160 amount
    )
        internal
        pure
        returns (IAllowanceTransfer.PermitDetails memory)
    {
        return IAllowanceTransfer.PermitDetails({
            token: asset,
            amount: amount,
            expiration: UINT48_MAX,
            nonce: PERMIT2_NONCE
        });
    }

    function permitDetailsWithNonce(
        address asset,
        uint160 amount,
        uint48 nonce
    )
        internal
        pure
        returns (IAllowanceTransfer.PermitDetails memory)
    {
        return IAllowanceTransfer.PermitDetails({ token: asset, amount: amount, expiration: UINT48_MAX, nonce: nonce });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                 SABLIER-V2-LOCKUP
    //////////////////////////////////////////////////////////////////////////*/

    function assets(IERC20 asset) internal pure returns (IERC20[] memory) {
        IERC20[] memory _assets = new IERC20[](1);
        _assets[0] = asset;
        return _assets;
    }

    function statusAfterCancel() internal pure returns (Lockup.Status) {
        return Lockup.Status.CANCELED;
    }

    function statusBeforeCancel() internal pure returns (Lockup.Status) {
        return Lockup.Status.ACTIVE;
    }

    function statusesAfterCancelMultiple() internal pure returns (Lockup.Status[] memory) {
        Lockup.Status[] memory _statuses = new Lockup.Status[](BATCH_COUNT);
        for (uint256 i = 0; i < BATCH_COUNT; ++i) {
            _statuses[i] = Lockup.Status.CANCELED;
        }
        return _statuses;
    }

    function statusesBeforeCancelMultiple() internal pure returns (Lockup.Status[] memory) {
        Lockup.Status[] memory _statuses = new Lockup.Status[](BATCH_COUNT);
        for (uint256 i = 0; i < BATCH_COUNT; ++i) {
            _statuses[i] = Lockup.Status.ACTIVE;
        }
        return _statuses;
    }

    function streamIds() internal pure returns (uint256[] memory) {
        uint256[] memory _streamIds = new uint256[](BATCH_COUNT);
        for (uint256 i = 0; i < BATCH_COUNT; ++i) {
            _streamIds[i] = i + 1;
        }
        return _streamIds;
    }

    /*//////////////////////////////////////////////////////////////////////////
                             SABLIER-V2-LOCKUP-DYNAMIC
    //////////////////////////////////////////////////////////////////////////*/

    function createWithDeltas(
        Users memory users,
        address proxy,
        IERC20 asset
    )
        internal
        pure
        returns (LockupDynamic.CreateWithDeltas memory)
    {
        return LockupDynamic.CreateWithDeltas({
            sender: proxy,
            recipient: users.recipient,
            totalAmount: AMOUNT,
            asset: asset,
            cancelable: true,
            segments: segmentsWithDeltas({ amount0: 2500e18, amount1: 7500e18 }),
            broker: Broker({ account: users.broker, fee: BROKER_FEE })
        });
    }

    function createWithMilestones(
        Users memory user,
        address proxy,
        IERC20 asset
    )
        internal
        pure
        returns (LockupDynamic.CreateWithMilestones memory)
    {
        return LockupDynamic.CreateWithMilestones({
            sender: proxy,
            recipient: user.recipient,
            totalAmount: AMOUNT,
            asset: asset,
            cancelable: true,
            segments: segments({ amount0: 2500e18, amount1: 7500e18 }),
            startTime: START_TIME,
            broker: Broker({ account: user.broker, fee: BROKER_FEE })
        });
    }

    function dynamicRange() internal pure returns (LockupDynamic.Range memory) {
        return LockupDynamic.Range({ start: START_TIME, end: END_TIME });
    }

    /// @dev Helper function to return an array of `LockupDynamic.Segment`.
    function segments(uint128 amount0, uint128 amount1) internal pure returns (LockupDynamic.Segment[] memory) {
        LockupDynamic.Segment[] memory _segments = new LockupDynamic.Segment[](2);

        _segments[0] = LockupDynamic.Segment({
            amount: amount0,
            exponent: ud2x18(3.14e18),
            milestone: START_TIME + CLIFF_DURATION
        });
        _segments[1] = LockupDynamic.Segment({
            amount: amount1,
            exponent: ud2x18(3.14e18),
            milestone: START_TIME + TOTAL_DURATION
        });

        return _segments;
    }

    /// @dev Helper function to return an array of `LockupDynamic.SegmentWithDelta`.
    function segmentsWithDeltas(
        uint128 amount0,
        uint128 amount1
    )
        internal
        pure
        returns (LockupDynamic.SegmentWithDelta[] memory)
    {
        LockupDynamic.SegmentWithDelta[] memory _segments = new LockupDynamic.SegmentWithDelta[](2);

        _segments[0] =
            LockupDynamic.SegmentWithDelta({ amount: amount0, delta: 2500 seconds, exponent: ud2x18(3.14e18) });
        _segments[1] =
            LockupDynamic.SegmentWithDelta({ amount: amount1, delta: 7500 seconds, exponent: ud2x18(3.14e18) });

        return _segments;
    }

    /*//////////////////////////////////////////////////////////////////////////
                             SABLIER-V2-LOCKUP-LINEAR
    //////////////////////////////////////////////////////////////////////////*/

    function durations() internal pure returns (LockupLinear.Durations memory) {
        return LockupLinear.Durations({ cliff: CLIFF_DURATION, total: TOTAL_DURATION });
    }

    function createWithDurations(
        Users memory users,
        address proxy,
        IERC20 asset
    )
        internal
        pure
        returns (LockupLinear.CreateWithDurations memory)
    {
        return LockupLinear.CreateWithDurations({
            sender: proxy,
            recipient: users.recipient,
            totalAmount: AMOUNT,
            asset: asset,
            cancelable: true,
            durations: durations(),
            broker: Broker({ account: users.broker, fee: BROKER_FEE })
        });
    }

    function createWithRange(
        Users memory users,
        address proxy,
        IERC20 asset
    )
        internal
        pure
        returns (LockupLinear.CreateWithRange memory)
    {
        return LockupLinear.CreateWithRange({
            sender: proxy,
            recipient: users.recipient,
            totalAmount: AMOUNT,
            asset: asset,
            cancelable: true,
            range: linearRange(),
            broker: Broker({ account: users.broker, fee: BROKER_FEE })
        });
    }

    function linearRange() internal pure returns (LockupLinear.Range memory) {
        return LockupLinear.Range({ start: START_TIME, cliff: CLIFF_TIME, end: END_TIME });
    }

    /*//////////////////////////////////////////////////////////////////////////
                              SABLIER-V2-PROXY-TARGET
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Helper function to return an array of `Batch.CreateWithDeltas`.
    function batchCreateWithDeltas(
        Users memory users,
        address proxy
    )
        internal
        pure
        returns (Batch.CreateWithDeltas[] memory)
    {
        Batch.CreateWithDeltas[] memory params = new Batch.CreateWithDeltas[](BATCH_COUNT);

        for (uint256 i = 0; i < BATCH_COUNT; ++i) {
            params[i] = Batch.CreateWithDeltas({
                amount: AMOUNT,
                broker: Broker({ account: users.broker, fee: BROKER_FEE }),
                cancelable: true,
                recipient: users.recipient,
                segments: segmentsWithDeltas({ amount0: 2500e18, amount1: 7500e18 }),
                sender: proxy
            });
        }

        return params;
    }

    /// @dev Helper function to return an array of `Batch.CreateWithDurations`.
    function batchCreateWithDurations(
        Users memory users,
        address proxy
    )
        internal
        pure
        returns (Batch.CreateWithDurations[] memory)
    {
        Batch.CreateWithDurations[] memory params = new Batch.CreateWithDurations[](BATCH_COUNT);

        for (uint256 i = 0; i < BATCH_COUNT; ++i) {
            params[i] = Batch.CreateWithDurations({
                amount: AMOUNT,
                broker: Broker({ account: users.broker, fee: BROKER_FEE }),
                cancelable: true,
                durations: durations(),
                recipient: users.recipient,
                sender: proxy
            });
        }

        return params;
    }

    /// @dev Helper function to return an array of `Batch.CreateWithMilestones`.
    function batchCreateWithMilestones(
        Users memory users,
        address proxy
    )
        internal
        pure
        returns (Batch.CreateWithMilestones[] memory)
    {
        Batch.CreateWithMilestones[] memory params = new Batch.CreateWithMilestones[](BATCH_COUNT);

        for (uint256 i = 0; i < BATCH_COUNT; ++i) {
            params[i] = Batch.CreateWithMilestones({
                amount: AMOUNT,
                broker: Broker({ account: users.broker, fee: BROKER_FEE }),
                cancelable: true,
                recipient: users.recipient,
                segments: segments({ amount0: 2500e18, amount1: 7500e18 }),
                sender: proxy,
                startTime: START_TIME
            });
        }

        return params;
    }

    /// @dev Helper function to return an array of `Batch.CreateWithRange`.
    function batchCreateWithRange(
        Users memory users,
        address proxy
    )
        internal
        pure
        returns (Batch.CreateWithRange[] memory)
    {
        Batch.CreateWithRange[] memory params = new Batch.CreateWithRange[](BATCH_COUNT);

        for (uint256 i = 0; i < BATCH_COUNT; ++i) {
            params[i] = Batch.CreateWithRange({
                amount: AMOUNT,
                broker: Broker({ account: users.broker, fee: BROKER_FEE }),
                cancelable: true,
                range: linearRange(),
                recipient: users.recipient,
                sender: proxy
            });
        }

        return params;
    }
}
