// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <0.9.0;

import { Arrays } from "@openzeppelin/contracts/utils/Arrays.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ud2x18 } from "@prb/math/src/UD2x18.sol";
import { UD60x18 } from "@prb/math/src/UD60x18.sol";
import { Broker, LockupDynamic, LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { Batch } from "src/types/DataTypes.sol";

import { ArrayBuilder } from "./ArrayBuilder.sol";
import { BatchBuilder } from "./BatchBuilder.sol";
import { Merkle } from "./Murky.sol";
import { MerkleBuilder } from "./MerkleBuilder.sol";
import { Users } from "./Types.sol";

/// @notice Contract with default values for testing.
contract Defaults is Merkle {
    using MerkleBuilder for uint256[];

    /*//////////////////////////////////////////////////////////////////////////
                                      GENERICS
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
                                  MERKLE-STREAMER
    //////////////////////////////////////////////////////////////////////////*/

    uint256 public constant AGGREGATE_AMOUNT = CLAIM_AMOUNT * RECIPIENTS_COUNT;
    bool public constant CANCELABLE = false;
    uint128 public constant CLAIM_AMOUNT = 10_000e18;
    uint40 public immutable EXPIRATION;
    uint256 public constant INDEX1 = 1;
    uint256 public constant INDEX2 = 2;
    uint256 public constant INDEX3 = 3;
    uint256 public constant INDEX4 = 4;
    string public constant IPFS_CID = "QmbWqxBEKC3P8tqsKc98xmWNzrzDtRLMiMPL8wBuTGsMnR";
    uint256 public constant RECIPIENTS_COUNT = 4;
    bool public constant TRANSFERABLE = false;
    uint256[] public LEAVES = new uint256[](RECIPIENTS_COUNT);
    bytes32 public immutable MERKLE_ROOT;

    /*//////////////////////////////////////////////////////////////////////////
                                     VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    IERC20 private asset;
    Users private users;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor(Users memory users_, IERC20 asset_) {
        users = users_;
        asset = asset_;

        // Initialize the immutables.
        START_TIME = uint40(block.timestamp) + 100 seconds;
        CLIFF_TIME = START_TIME + CLIFF_DURATION;
        END_TIME = START_TIME + TOTAL_DURATION;
        EXPIRATION = uint40(block.timestamp) + 12 weeks;

        // Initialize the Merkle tree.
        LEAVES[0] = MerkleBuilder.computeLeaf(INDEX1, users.recipient1, CLAIM_AMOUNT);
        LEAVES[1] = MerkleBuilder.computeLeaf(INDEX2, users.recipient2, CLAIM_AMOUNT);
        LEAVES[2] = MerkleBuilder.computeLeaf(INDEX3, users.recipient3, CLAIM_AMOUNT);
        LEAVES[3] = MerkleBuilder.computeLeaf(INDEX4, users.recipient4, CLAIM_AMOUNT);
        MerkleBuilder.sortLeaves(LEAVES);
        MERKLE_ROOT = getRoot(LEAVES.toBytes32());
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  MERKLE-STREAMER
    //////////////////////////////////////////////////////////////////////////*/

    function index1Proof() public view returns (bytes32[] memory) {
        uint256 leaf = MerkleBuilder.computeLeaf(INDEX1, users.recipient1, CLAIM_AMOUNT);
        uint256 pos = Arrays.findUpperBound(LEAVES, leaf);
        return getProof(LEAVES.toBytes32(), pos);
    }

    function index2Proof() public view returns (bytes32[] memory) {
        uint256 leaf = MerkleBuilder.computeLeaf(INDEX2, users.recipient2, CLAIM_AMOUNT);
        uint256 pos = Arrays.findUpperBound(LEAVES, leaf);
        return getProof(LEAVES.toBytes32(), pos);
    }

    function index3Proof() public view returns (bytes32[] memory) {
        uint256 leaf = MerkleBuilder.computeLeaf(INDEX3, users.recipient3, CLAIM_AMOUNT);
        uint256 pos = Arrays.findUpperBound(LEAVES, leaf);
        return getProof(LEAVES.toBytes32(), pos);
    }

    function index4Proof() public view returns (bytes32[] memory) {
        uint256 leaf = MerkleBuilder.computeLeaf(INDEX4, users.recipient4, CLAIM_AMOUNT);
        uint256 pos = Arrays.findUpperBound(LEAVES, leaf);
        return getProof(LEAVES.toBytes32(), pos);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                 SABLIER-V2-LOCKUP
    //////////////////////////////////////////////////////////////////////////*/

    function assets() public view returns (IERC20[] memory assets_) {
        assets_ = new IERC20[](1);
        assets_[0] = asset;
    }

    function broker() public view returns (Broker memory) {
        return Broker({ account: users.broker, fee: BROKER_FEE });
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
            recipient: users.recipient0,
            segments: segmentsWithDeltas(),
            sender: users.alice,
            totalAmount: PER_STREAM_AMOUNT,
            transferable: true
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
            recipient: users.recipient0,
            segments: segments(),
            sender: users.alice,
            startTime: START_TIME,
            totalAmount: PER_STREAM_AMOUNT,
            transferable: true
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
    function segmentsWithDeltas() public pure returns (LockupDynamic.SegmentWithDelta[] memory) {
        return segmentsWithDeltas({ amount0: 2500e18, amount1: 7500e18 });
    }

    /// @dev Returns a batch of `LockupDynamic.SegmentWithDelta` parameters.
    function segmentsWithDeltas(
        uint128 amount0,
        uint128 amount1
    )
        public
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
            recipient: users.recipient0,
            sender: users.alice,
            totalAmount: PER_STREAM_AMOUNT,
            transferable: true
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
            recipient: users.recipient0,
            sender: users.alice,
            totalAmount: PER_STREAM_AMOUNT,
            transferable: true
        });
    }

    function durations() public pure returns (LockupLinear.Durations memory) {
        return LockupLinear.Durations({ cliff: CLIFF_DURATION, total: TOTAL_DURATION });
    }

    function linearRange() private view returns (LockupLinear.Range memory) {
        return LockupLinear.Range({ start: START_TIME, cliff: CLIFF_TIME, end: END_TIME });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                        BATCH
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Returns a default-size batch of `Batch.CreateWithDeltas` parameters.
    function batchCreateWithDeltas() public view returns (Batch.CreateWithDeltas[] memory batch) {
        batch = BatchBuilder.fillBatch(createWithDeltas(), BATCH_SIZE);
    }

    /// @dev Returns a default-size batch of `Batch.CreateWithDurations` parameters.
    function batchCreateWithDurations() public view returns (Batch.CreateWithDurations[] memory batch) {
        batch = BatchBuilder.fillBatch(createWithDurations(), BATCH_SIZE);
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
        batch = BatchBuilder.fillBatch(createWithMilestones(), batchSize);
    }

    /// @dev Returns a default-size batch of `Batch.CreateWithRange` parameters.
    function batchCreateWithRange() public view returns (Batch.CreateWithRange[] memory batch) {
        batch = batchCreateWithRange(BATCH_SIZE);
    }

    /// @dev Returns a batch of `Batch.CreateWithRange` parameters.
    function batchCreateWithRange(uint256 batchSize) public view returns (Batch.CreateWithRange[] memory batch) {
        batch = BatchBuilder.fillBatch(createWithRange(), batchSize);
    }
}
