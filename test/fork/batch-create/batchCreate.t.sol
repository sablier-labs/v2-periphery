// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { LockupDynamic, LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { Batch } from "src/types/DataTypes.sol";

import { Fork_Test } from "../Fork.t.sol";
import { ArrayBuilder } from "../../utils/ArrayBuilder.sol";
import { BatchBuilder } from "../../utils/BatchBuilder.sol";

/// @dev Runs against multiple fork assets.
abstract contract BatchCreate_Fork_Test is Fork_Test {
    constructor(IERC20 asset_) Fork_Test(asset_) { }

    function setUp() public virtual override {
        Fork_Test.setUp();
    }

    /*//////////////////////////////////////////////////////////////////////////
                            BATCH-CREATE-WITH-MILESTONES
    //////////////////////////////////////////////////////////////////////////*/

    struct CreateWithMilestonesParams {
        uint128 batchSize;
        address sender;
        address recipient;
        uint128 perStreamAmount;
        uint40 startTime;
        LockupDynamic.Segment[] segments;
    }

    function testForkFuzz_BatchCreateWithMilestones(CreateWithMilestonesParams memory params) external {
        vm.assume(params.segments.length != 0);
        params.batchSize = boundUint128(params.batchSize, 1, 20);
        params.startTime = boundUint40(params.startTime, getBlockTimestamp(), getBlockTimestamp() + 24 hours);
        fuzzSegmentMilestones(params.segments, params.startTime);
        (params.perStreamAmount,) = fuzzDynamicStreamAmounts({
            upperBound: MAX_UINT128 / params.batchSize,
            segments: params.segments,
            protocolFee: defaults.PROTOCOL_FEE(),
            brokerFee: defaults.BROKER_FEE()
        });

        checkUsers(params.sender, params.recipient);

        uint256 firstStreamId = lockupDynamic.nextStreamId();
        uint128 totalTransferAmount = params.perStreamAmount * params.batchSize;

        deal({ token: address(asset), to: params.sender, give: uint256(totalTransferAmount) });
        changePrank({ msgSender: params.sender });
        asset.approve({ spender: address(batchCreate), amount: totalTransferAmount });

        LockupDynamic.CreateWithMilestones memory createWithMilestones = LockupDynamic.CreateWithMilestones({
            asset: asset,
            broker: defaults.broker(),
            cancelable: true,
            recipient: params.recipient,
            segments: params.segments,
            sender: params.sender,
            startTime: params.startTime,
            totalAmount: params.perStreamAmount
        });
        Batch.CreateWithMilestones[] memory batch = BatchBuilder.fillBatch(createWithMilestones, params.batchSize);

        expectCallToTransferFrom({
            asset_: address(asset),
            from: params.sender,
            to: address(batchCreate),
            amount: totalTransferAmount
        });
        expectMultipleCallsToCreateWithMilestones({ count: uint64(params.batchSize), params: createWithMilestones });
        expectMultipleCallsToTransferFrom({
            asset_: address(asset),
            count: uint64(params.batchSize),
            from: address(batchCreate),
            to: address(lockupDynamic),
            amount: params.perStreamAmount
        });

        uint256[] memory actualStreamIds = batchCreate.batchCreateWithMilestones(lockupDynamic, asset, batch);
        uint256[] memory expectedStreamIds = ArrayBuilder.fillStreamIds(firstStreamId, params.batchSize);
        assertEq(actualStreamIds, expectedStreamIds);
    }

    /*//////////////////////////////////////////////////////////////////////////
                              BATCH-CREATE-WITH-RANGE
    //////////////////////////////////////////////////////////////////////////*/

    struct CreateWithRangeParams {
        uint128 batchSize;
        LockupLinear.Range range;
        address sender;
        address recipient;
        uint128 perStreamAmount;
    }

    function testForkFuzz_BatchCreateWithRange(CreateWithRangeParams memory params) external {
        params.batchSize = boundUint128(params.batchSize, 1, 20);
        params.perStreamAmount = boundUint128(params.perStreamAmount, 1, MAX_UINT128 / params.batchSize);
        params.range.start = boundUint40(params.range.start, getBlockTimestamp(), getBlockTimestamp() + 24 hours);
        params.range.cliff = boundUint40(params.range.cliff, params.range.start, params.range.start + 52 weeks);
        params.range.end = boundUint40(params.range.end, params.range.cliff + 1 seconds, MAX_UNIX_TIMESTAMP);

        checkUsers(params.sender, params.recipient);

        uint256 firstStreamId = lockupLinear.nextStreamId();
        uint128 totalTransferAmount = params.perStreamAmount * params.batchSize;

        deal({ token: address(asset), to: params.sender, give: uint256(totalTransferAmount) });
        changePrank({ msgSender: params.sender });
        asset.approve({ spender: address(batchCreate), amount: totalTransferAmount });

        LockupLinear.CreateWithRange memory createParams = LockupLinear.CreateWithRange({
            asset: asset,
            broker: defaults.broker(),
            cancelable: true,
            recipient: params.recipient,
            sender: params.sender,
            range: params.range,
            totalAmount: params.perStreamAmount
        });
        Batch.CreateWithRange[] memory batch = BatchBuilder.fillBatch(createParams, params.batchSize);

        // Asset flow: sender → batchCreate → Sablier
        expectCallToTransferFrom({
            asset_: address(asset),
            from: params.sender,
            to: address(batchCreate),
            amount: totalTransferAmount
        });
        expectMultipleCallsToCreateWithRange({ count: uint64(params.batchSize), params: createParams });
        expectMultipleCallsToTransferFrom({
            asset_: address(asset),
            count: uint64(params.batchSize),
            from: address(batchCreate),
            to: address(lockupLinear),
            amount: params.perStreamAmount
        });

        uint256[] memory actualStreamIds = batchCreate.batchCreateWithRange(lockupLinear, asset, batch);
        uint256[] memory expectedStreamIds = ArrayBuilder.fillStreamIds(firstStreamId, params.batchSize);
        assertEq(actualStreamIds, expectedStreamIds);
    }
}
