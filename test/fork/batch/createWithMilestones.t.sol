// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { LockupDynamic } from "@sablier/v2-core/src/types/DataTypes.sol";

import { Batch } from "src/types/DataTypes.sol";

import { Fork_Test } from "../Fork.t.sol";
import { ArrayBuilder } from "../../utils/ArrayBuilder.sol";
import { BatchBuilder } from "../../utils/BatchBuilder.sol";

/// @dev Runs against multiple fork assets.
abstract contract CreateWithMilestones_Batch_Fork_Test is Fork_Test {
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

    function testForkFuzz_CreateWithMilestones(CreateWithMilestonesParams memory params) external {
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
        asset.approve({ spender: address(batch), amount: totalTransferAmount });

        LockupDynamic.CreateWithMilestones memory createWithMilestones = LockupDynamic.CreateWithMilestones({
            asset: asset,
            broker: defaults.broker(),
            cancelable: true,
            recipient: params.recipient,
            segments: params.segments,
            sender: params.sender,
            startTime: params.startTime,
            totalAmount: params.perStreamAmount,
            transferable: true
        });
        Batch.CreateWithMilestones[] memory batchParams = BatchBuilder.fillBatch(createWithMilestones, params.batchSize);

        expectCallToTransferFrom({
            asset_: address(asset),
            from: params.sender,
            to: address(batch),
            amount: totalTransferAmount
        });
        expectMultipleCallsToCreateWithMilestones({ count: uint64(params.batchSize), params: createWithMilestones });
        expectMultipleCallsToTransferFrom({
            asset_: address(asset),
            count: uint64(params.batchSize),
            from: address(batch),
            to: address(lockupDynamic),
            amount: params.perStreamAmount
        });

        uint256[] memory actualStreamIds = batch.createWithMilestones(lockupDynamic, asset, batchParams);
        uint256[] memory expectedStreamIds = ArrayBuilder.fillStreamIds(firstStreamId, params.batchSize);
        assertEq(actualStreamIds, expectedStreamIds);
    }
}
