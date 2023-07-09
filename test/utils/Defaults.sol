// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IPRBProxy } from "@prb/proxy/interfaces/IPRBProxy.sol";
import { ud2x18, UD60x18 } from "@sablier/v2-core/types/Math.sol";
import { Broker, LockupDynamic, LockupLinear } from "@sablier/v2-core/types/DataTypes.sol";
import { IAllowanceTransfer } from "permit2/interfaces/IAllowanceTransfer.sol";
import { PermitSignature } from "permit2-test/utils/PermitSignature.sol";

import { Batch } from "src/types/DataTypes.sol";
import { Permit2Params } from "src/types/Permit2.sol";

import { ArrayBuilder } from "./ArrayBuilder.sol";
import { BatchBuilder } from "./BatchBuilder.sol";
import { Users } from "./Types.sol";

/// @notice Contract with default values for testing.
contract Defaults is PermitSignature {
    /*//////////////////////////////////////////////////////////////////////////
                                 GENERIC CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    uint64 public constant BATCH_SIZE = 10;
    UD60x18 public constant BROKER_FEE = UD60x18.wrap(0);
    uint40 public constant CLIFF_DURATION = 2500 seconds;
    uint40 public immutable CLIFF_TIME;
    uint40 public immutable END_TIME;
    uint256 public constant ETHER_AMOUNT = 10_000 ether;
    uint256 public constant MAX_SEGMENT_COUNT = 1000;
    uint128 public constant PER_STREAM_AMOUNT = 10_000e18;
    UD60x18 public constant PROTOCOL_FEE = UD60x18.wrap(0);
    uint128 public constant REFUND_AMOUNT = 7500e18; // deposit - cliff amount
    uint40 public immutable START_TIME;
    uint40 public constant TOTAL_DURATION = 10_000 seconds;
    uint128 public constant TOTAL_TRANSFER_AMOUNT = PER_STREAM_AMOUNT * uint128(BATCH_SIZE);
    uint128 public constant WITHDRAW_AMOUNT = 2500e18;

    /*//////////////////////////////////////////////////////////////////////////
                                 PERMIT2 CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    uint48 public constant PERMIT2_EXPIRATION = type(uint48).max;
    uint256 public constant PERMIT2_SIG_DEADLINE = type(uint48).max;

    /*//////////////////////////////////////////////////////////////////////////
                                     VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    IERC20 private asset;
    IPRBProxy private proxy;
    IAllowanceTransfer private permit2;
    Users private users;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor(Users memory users_, IERC20 asset_, IAllowanceTransfer permit2_, IPRBProxy proxy_) {
        users = users_;
        asset = asset_;
        permit2 = permit2_;
        proxy = proxy_;

        // Initialize the immutables.
        START_TIME = uint40(block.timestamp) + 100 seconds;
        CLIFF_TIME = START_TIME + CLIFF_DURATION;
        END_TIME = START_TIME + TOTAL_DURATION;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                       PARAMS
    //////////////////////////////////////////////////////////////////////////*/

    function permit2Params(uint160 amount) public view returns (Permit2Params memory permit2Params_) {
        permit2Params_ = permit2Params(users.alice.addr, address(proxy), amount, users.alice.key);
    }

    function permit2Params(
        address user,
        address spender,
        uint160 amount,
        uint256 privateKey
    )
        public
        view
        returns (Permit2Params memory permit2Params_)
    {
        (,, uint48 nonce) = permit2.allowance({ user: user, token: address(asset), spender: spender });
        IAllowanceTransfer.PermitSingle memory permitSingle = IAllowanceTransfer.PermitSingle({
            details: IAllowanceTransfer.PermitDetails({
                amount: amount,
                expiration: PERMIT2_EXPIRATION,
                nonce: nonce,
                token: address(asset)
            }),
            sigDeadline: PERMIT2_SIG_DEADLINE,
            spender: spender
        });
        permit2Params_ = Permit2Params({
            permitSingle: permitSingle,
            signature: getPermitSignature({
                permit: permitSingle,
                privateKey: privateKey,
                domainSeparator: permit2.DOMAIN_SEPARATOR()
            })
        });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                 SABLIER-V2-LOCKUP
    //////////////////////////////////////////////////////////////////////////*/

    function assets() public view returns (IERC20[] memory assets_) {
        assets_ = new IERC20[](1);
        assets_[0] = asset;
    }

    function broker() public view returns (Broker memory) {
        return Broker({ account: users.broker.addr, fee: BROKER_FEE });
    }

    function incrementalStreamIds() public pure returns (uint256[] memory streamIds) {
        return ArrayBuilder.fillStreamIds({ firstStreamId: 1, batchSize: BATCH_SIZE });
    }

    /*//////////////////////////////////////////////////////////////////////////
                             SABLIER-V2-LOCKUP-DYNAMIC
    //////////////////////////////////////////////////////////////////////////*/

    function createWithDeltas() public view returns (LockupDynamic.CreateWithDeltas memory) {
        return createWithDeltas(asset);
    }

    function createWithDeltas(IERC20 asset_) public view returns (LockupDynamic.CreateWithDeltas memory) {
        return LockupDynamic.CreateWithDeltas({
            asset: asset_,
            broker: broker(),
            cancelable: true,
            recipient: users.recipient.addr,
            segments: segmentsWithDeltas({ amount0: 2500e18, amount1: 7500e18 }),
            sender: address(proxy),
            totalAmount: PER_STREAM_AMOUNT
        });
    }

    function createWithMilestones() public view returns (LockupDynamic.CreateWithMilestones memory) {
        return createWithMilestones(asset);
    }

    function createWithMilestones(IERC20 asset_) public view returns (LockupDynamic.CreateWithMilestones memory) {
        return LockupDynamic.CreateWithMilestones({
            asset: asset_,
            broker: broker(),
            cancelable: true,
            recipient: users.recipient.addr,
            segments: segments(),
            sender: address(proxy),
            startTime: START_TIME,
            totalAmount: PER_STREAM_AMOUNT
        });
    }

    function dynamicRange() public view returns (LockupDynamic.Range memory) {
        return LockupDynamic.Range({ start: START_TIME, end: END_TIME });
    }

    /// @dev Returns a batch of `LockupDynamic.Segment` parameters.
    function segments() private view returns (LockupDynamic.Segment[] memory segments_) {
        segments_ = new LockupDynamic.Segment[](2);
        segments_[0] = LockupDynamic.Segment({
            amount: 2500e18,
            exponent: ud2x18(3.14e18),
            milestone: START_TIME + CLIFF_DURATION
        });
        segments_[1] = LockupDynamic.Segment({
            amount: 7500e18,
            exponent: ud2x18(3.14e18),
            milestone: START_TIME + TOTAL_DURATION
        });
    }

    /// @dev Returns a batch of `LockupDynamic.SegmentWithDelta` parameters.
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

    function createWithDurations() public view returns (LockupLinear.CreateWithDurations memory) {
        return createWithDurations(asset);
    }

    function createWithDurations(IERC20 asset_) public view returns (LockupLinear.CreateWithDurations memory) {
        return LockupLinear.CreateWithDurations({
            asset: asset_,
            broker: broker(),
            cancelable: true,
            durations: durations(),
            recipient: users.recipient.addr,
            sender: address(proxy),
            totalAmount: PER_STREAM_AMOUNT
        });
    }

    function createWithRange() public view returns (LockupLinear.CreateWithRange memory) {
        return createWithRange(asset);
    }

    function createWithRange(IERC20 asset_) public view returns (LockupLinear.CreateWithRange memory) {
        return LockupLinear.CreateWithRange({
            asset: asset_,
            broker: broker(),
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

    /// @dev Returns a default-size batch of `Batch.CreateWithDeltas` parameters.
    function batchCreateWithDeltas() public view returns (Batch.CreateWithDeltas[] memory batch) {
        batch = BatchBuilder.generateBatchFromParams(createWithDeltas(), BATCH_SIZE);
    }

    /// @dev Returns a default-size batch of `Batch.CreateWithDurations` parameters.
    function batchCreateWithDurations() public view returns (Batch.CreateWithDurations[] memory batch) {
        batch = BatchBuilder.generateBatchFromParams(createWithDurations(), BATCH_SIZE);
    }

    /// @dev Returns a default-size batch of `Batch.CreateWithMilestones` parameters.
    function batchCreateWithMilestones() public view returns (Batch.CreateWithMilestones[] memory batch) {
        batch = batchCreateWithMilestones(BATCH_SIZE);
    }

    /// @dev Returns a batch of `Batch.CreateWithMilestones` parameters.
    function batchCreateWithMilestones(uint256 batchSize)
        public
        view
        returns (Batch.CreateWithMilestones[] memory batch)
    {
        batch = BatchBuilder.generateBatchFromParams(createWithMilestones(), batchSize);
    }

    /// @dev Returns a default-size batch of `Batch.CreateWithRange` parameters.
    function batchCreateWithRange() public view returns (Batch.CreateWithRange[] memory batch) {
        batch = batchCreateWithRange(BATCH_SIZE);
    }

    /// @dev Returns a batch of `Batch.CreateWithRange` parameters.
    function batchCreateWithRange(uint256 batchSize) public view returns (Batch.CreateWithRange[] memory batch) {
        batch = BatchBuilder.generateBatchFromParams(createWithRange(), batchSize);
    }
}
