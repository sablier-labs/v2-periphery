// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { IPRBProxy } from "@prb/proxy/interfaces/IPRBProxy.sol";
import { ud2x18, UD60x18 } from "@sablier/v2-core/types/Math.sol";
import { Broker, Lockup, LockupDynamic, LockupLinear } from "@sablier/v2-core/types/DataTypes.sol";
import { IAllowanceTransfer } from "permit2/interfaces/IAllowanceTransfer.sol";

import { Batch, Permit2Params } from "src/types/DataTypes.sol";

import { Users } from "./Types.sol";

/// @notice Contract with default values for testing.
contract Defaults {
    /*//////////////////////////////////////////////////////////////////////////
                                 GENERIC CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    uint64 public constant BATCH_SIZE = 10;
    Broker public BROKER;
    UD60x18 public constant BROKER_FEE = UD60x18.wrap(0);
    uint40 public constant CLIFF_DURATION = 2500 seconds;
    uint40 public immutable CLIFF_TIME;
    uint40 public immutable END_TIME;
    uint256 public constant ETHER_AMOUNT = 10_000 ether;
    uint256 public constant MAX_SEGMENT_COUNT = 1000;
    uint128 public constant PER_STREAM_AMOUNT = 10_000e18;
    uint128 public constant REFUND_AMOUNT = 7500e18; // deposit - cliff amount
    uint40 public immutable START_TIME;
    uint40 public constant TOTAL_DURATION = 10_000 seconds;
    uint128 public constant TRANSFER_AMOUNT = PER_STREAM_AMOUNT * uint128(BATCH_SIZE);
    uint128 public constant WITHDRAW_AMOUNT = 2500e18;

    /*//////////////////////////////////////////////////////////////////////////
                                 PERMIT2 CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    uint48 public constant PERMIT2_EXPIRATION = type(uint48).max;
    uint48 public constant PERMIT2_NONCE = 0;
    uint256 public immutable PERMIT2_SIG_DEADLINE;

    /*//////////////////////////////////////////////////////////////////////////
                                     VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    IPRBProxy private proxy;
    IERC20 private usdc;
    Users private users;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor(Users memory users_, IERC20 usdc_, IPRBProxy proxy_) {
        users = users_;
        usdc = usdc_;
        proxy = proxy_;

        // Initialize the immutables.
        START_TIME = uint40(block.timestamp) + 100 seconds;
        CLIFF_TIME = START_TIME + CLIFF_DURATION;
        END_TIME = START_TIME + TOTAL_DURATION;
        PERMIT2_SIG_DEADLINE = START_TIME;

        // Initialize the complex constants.
        BROKER = Broker({ account: users.broker.addr, fee: BROKER_FEE });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                       PARAMS
    //////////////////////////////////////////////////////////////////////////*/

    function permitDetails(uint160 amount) external view returns (IAllowanceTransfer.PermitDetails memory details) {
        details = IAllowanceTransfer.PermitDetails({
            amount: amount,
            expiration: PERMIT2_EXPIRATION,
            nonce: PERMIT2_NONCE,
            token: address(usdc)
        });
    }

    function permitDetails(
        uint160 amount,
        uint48 nonce
    )
        external
        view
        returns (IAllowanceTransfer.PermitDetails memory details)
    {
        details = IAllowanceTransfer.PermitDetails({
            amount: amount,
            expiration: PERMIT2_EXPIRATION,
            nonce: nonce,
            token: address(usdc)
        });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                 SABLIER-V2-LOCKUP
    //////////////////////////////////////////////////////////////////////////*/

    function assets() external view returns (IERC20[] memory assets_) {
        assets_ = new IERC20[](1);
        assets_[0] = usdc;
    }

    function incrementalStreamIds() external pure returns (uint256[] memory streamIds) {
        streamIds = new uint256[](BATCH_SIZE);
        for (uint256 i = 0; i < BATCH_SIZE; ++i) {
            streamIds[i] = i + 1;
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                             SABLIER-V2-LOCKUP-DYNAMIC
    //////////////////////////////////////////////////////////////////////////*/

    function createWithDeltas() external view returns (LockupDynamic.CreateWithDeltas memory params) {
        params = createWithDeltas(usdc);
    }

    function createWithDeltas(IERC20 asset) public view returns (LockupDynamic.CreateWithDeltas memory params) {
        params = LockupDynamic.CreateWithDeltas({
            asset: asset,
            broker: BROKER,
            cancelable: true,
            recipient: users.recipient.addr,
            segments: segmentsWithDeltas({ amount0: 2500e18, amount1: 7500e18 }),
            sender: address(proxy),
            totalAmount: PER_STREAM_AMOUNT
        });
    }

    function createWithMilestones() external view returns (LockupDynamic.CreateWithMilestones memory params) {
        params = createWithMilestones(usdc);
    }

    function createWithMilestones(IERC20 asset)
        public
        view
        returns (LockupDynamic.CreateWithMilestones memory params)
    {
        params = LockupDynamic.CreateWithMilestones({
            asset: asset,
            broker: BROKER,
            cancelable: true,
            recipient: users.recipient.addr,
            segments: segments({ amount0: 2500e18, amount1: 7500e18 }),
            sender: address(proxy),
            startTime: START_TIME,
            totalAmount: PER_STREAM_AMOUNT
        });
    }

    function dynamicRange() external view returns (LockupDynamic.Range memory) {
        return LockupDynamic.Range({ start: START_TIME, end: END_TIME });
    }

    /// @dev Helper function to return a batch of `LockupDynamic.Segment` parameters.
    function segments(
        uint128 amount0,
        uint128 amount1
    )
        private
        view
        returns (LockupDynamic.Segment[] memory segments_)
    {
        segments_ = new LockupDynamic.Segment[](2);
        segments_[0] = LockupDynamic.Segment({
            amount: amount0,
            exponent: ud2x18(3.14e18),
            milestone: START_TIME + CLIFF_DURATION
        });
        segments_[1] = LockupDynamic.Segment({
            amount: amount1,
            exponent: ud2x18(3.14e18),
            milestone: START_TIME + TOTAL_DURATION
        });
    }

    /// @dev Helper function to return a batch of `LockupDynamic.SegmentWithDelta` parameters.
    function segmentsWithDeltas(
        uint128 amount0,
        uint128 amount1
    )
        private
        pure
        returns (LockupDynamic.SegmentWithDelta[] memory segments_)
    {
        segments_ = new LockupDynamic.SegmentWithDelta[](2);
        segments_[0] =
            LockupDynamic.SegmentWithDelta({ amount: amount0, exponent: ud2x18(3.14e18), delta: 2500 seconds });
        segments_[1] =
            LockupDynamic.SegmentWithDelta({ amount: amount1, exponent: ud2x18(3.14e18), delta: 7500 seconds });
    }

    /*//////////////////////////////////////////////////////////////////////////
                             SABLIER-V2-LOCKUP-LINEAR
    //////////////////////////////////////////////////////////////////////////*/

    function createWithDurations() external view returns (LockupLinear.CreateWithDurations memory params) {
        params = createWithDurations(usdc);
    }

    function createWithDurations(IERC20 asset) public view returns (LockupLinear.CreateWithDurations memory params) {
        params = LockupLinear.CreateWithDurations({
            asset: asset,
            broker: BROKER,
            durations: durations(),
            cancelable: true,
            recipient: users.recipient.addr,
            sender: address(proxy),
            totalAmount: PER_STREAM_AMOUNT
        });
    }

    function createWithRange() external view returns (LockupLinear.CreateWithRange memory params) {
        params = createWithRange(usdc);
    }

    function createWithRange(IERC20 asset) public view returns (LockupLinear.CreateWithRange memory params) {
        params = LockupLinear.CreateWithRange({
            asset: asset,
            broker: BROKER,
            cancelable: true,
            range: linearRange(),
            recipient: users.recipient.addr,
            sender: address(proxy),
            totalAmount: PER_STREAM_AMOUNT
        });
    }

    function durations() private pure returns (LockupLinear.Durations memory) {
        return LockupLinear.Durations({ cliff: CLIFF_DURATION, total: TOTAL_DURATION });
    }

    function linearRange() private view returns (LockupLinear.Range memory) {
        return LockupLinear.Range({ start: START_TIME, cliff: CLIFF_TIME, end: END_TIME });
    }

    /*//////////////////////////////////////////////////////////////////////////
                              SABLIER-V2-PROXY-TARGET
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Helper function to return a batch of `Batch.CreateWithDeltas` parameters.
    function batchCreateWithDeltas() external view returns (Batch.CreateWithDeltas[] memory batch) {
        batch = new Batch.CreateWithDeltas[](BATCH_SIZE);
        for (uint256 i = 0; i < BATCH_SIZE; ++i) {
            batch[i] = Batch.CreateWithDeltas({
                broker: BROKER,
                cancelable: true,
                recipient: users.recipient.addr,
                segments: segmentsWithDeltas({ amount0: 2500e18, amount1: 7500e18 }),
                sender: address(proxy),
                totalAmount: PER_STREAM_AMOUNT
            });
        }
    }

    /// @dev Helper function to return a batch of `Batch.CreateWithDurations` parameters.
    function batchCreateWithDurations() external view returns (Batch.CreateWithDurations[] memory batch) {
        batch = new Batch.CreateWithDurations[](BATCH_SIZE);
        for (uint256 i = 0; i < BATCH_SIZE; ++i) {
            batch[i] = Batch.CreateWithDurations({
                broker: BROKER,
                cancelable: true,
                durations: durations(),
                recipient: users.recipient.addr,
                sender: address(proxy),
                totalAmount: PER_STREAM_AMOUNT
            });
        }
    }

    /// @dev Helper function to return a batch of `Batch.CreateWithMilestones` parameters.
    function batchCreateWithMilestones() external view returns (Batch.CreateWithMilestones[] memory batch) {
        batch = new Batch.CreateWithMilestones[](BATCH_SIZE);
        for (uint256 i = 0; i < BATCH_SIZE; ++i) {
            batch[i] = Batch.CreateWithMilestones({
                broker: BROKER,
                cancelable: true,
                recipient: users.recipient.addr,
                segments: segments({ amount0: 2500e18, amount1: 7500e18 }),
                sender: address(proxy),
                startTime: START_TIME,
                totalAmount: PER_STREAM_AMOUNT
            });
        }
    }

    /// @dev Helper function to return a batch of `Batch.CreateWithRange` parameters.
    function batchCreateWithRange() external view returns (Batch.CreateWithRange[] memory batch) {
        batch = new Batch.CreateWithRange[](BATCH_SIZE);
        for (uint256 i = 0; i < BATCH_SIZE; ++i) {
            batch[i] = Batch.CreateWithRange({
                broker: BROKER,
                cancelable: true,
                range: linearRange(),
                recipient: users.recipient.addr,
                sender: address(proxy),
                totalAmount: PER_STREAM_AMOUNT
            });
        }
    }
}
