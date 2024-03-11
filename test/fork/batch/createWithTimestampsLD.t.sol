// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { LockupDynamic } from "@sablier/v2-core/src/types/DataTypes.sol";

import { Batch } from "src/types/DataTypes.sol";

import { Fork_Test } from "../Fork.t.sol";
import { ArrayBuilder } from "../../utils/ArrayBuilder.sol";
import { BatchBuilder } from "../../utils/BatchBuilder.sol";

/// @dev Runs against multiple fork assets.
abstract contract CreateWithTimestamps_LockupDynamic_Batch_Fork_Test is Fork_Test {
    constructor(IERC20 asset_) Fork_Test(asset_) { }

    function setUp() public virtual override {
        Fork_Test.setUp();
    }

    /*//////////////////////////////////////////////////////////////////////////
                            BATCH-CREATE-WITH-TIMESTAMPS
    //////////////////////////////////////////////////////////////////////////*/

    struct CreateWithTimestampsParams {
        uint128 batchSize;
        address sender;
        address recipient;
        uint128 perStreamAmount;
        uint40 startTime;
        LockupDynamic.Segment[] segments;
    }

    function testForkFuzz_CreateWithTimestamps(CreateWithTimestampsParams memory params) external {
        vm.assume(params.segments.length != 0);
        params.batchSize = boundUint128(params.batchSize, 1, 20);
        params.startTime = boundUint40(params.startTime, getBlockTimestamp(), getBlockTimestamp() + 24 hours);
        fuzzSegmentTimestamps(params.segments, params.startTime);
        (params.perStreamAmount,) = fuzzDynamicStreamAmounts({
            upperBound: MAX_UINT128 / params.batchSize,
            segments: params.segments,
            brokerFee: defaults.BROKER_FEE()
        });

        checkUsers(params.sender, params.recipient);

        uint256 firstStreamId = lockupDynamic.nextStreamId();
        uint128 totalTransferAmount = params.perStreamAmount * params.batchSize;

        deal({ token: address(ASSET), to: params.sender, give: uint256(totalTransferAmount) });
        approveContract({ asset_: ASSET, from: params.sender, spender: address(batch) });

        LockupDynamic.CreateWithTimestamps memory createWithTimestamps = LockupDynamic.CreateWithTimestamps({
            sender: params.sender,
            recipient: params.recipient,
            totalAmount: params.perStreamAmount,
            asset: ASSET,
            cancelable: true,
            transferable: true,
            startTime: params.startTime,
            segments: params.segments,
            broker: defaults.broker()
        });
        Batch.CreateWithTimestampsLD[] memory batchParams =
            BatchBuilder.fillBatch(createWithTimestamps, params.batchSize);

        expectCallToTransferFrom({
            asset_: address(ASSET),
            from: params.sender,
            to: address(batch),
            amount: totalTransferAmount
        });
        expectMultipleCallsToCreateWithTimestampsLD({ count: uint64(params.batchSize), params: createWithTimestamps });
        expectMultipleCallsToTransferFrom({
            asset_: address(ASSET),
            count: uint64(params.batchSize),
            from: address(batch),
            to: address(lockupDynamic),
            amount: params.perStreamAmount
        });

        uint256[] memory actualStreamIds = batch.createWithTimestampsLD(lockupDynamic, ASSET, batchParams);
        uint256[] memory expectedStreamIds = ArrayBuilder.fillStreamIds(firstStreamId, params.batchSize);
        assertEq(actualStreamIds, expectedStreamIds);
    }
}
