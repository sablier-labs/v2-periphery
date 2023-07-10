// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IPRBProxy } from "@prb/proxy/interfaces/IPRBProxy.sol";
import { LockupDynamic, LockupLinear } from "@sablier/v2-core/types/DataTypes.sol";

import { PermitSignature } from "permit2-test/utils/PermitSignature.sol";

import { Batch } from "src/types/DataTypes.sol";
import { Permit2Params } from "src/types/Permit2.sol";

import { Fork_Test } from "../Fork.t.sol";
import { ArrayBuilder } from "../../utils/ArrayBuilder.sol";
import { BatchBuilder } from "../../utils/BatchBuilder.sol";

/// @dev Runs against multiple fork assets.
abstract contract BatchCreate_Fork_Test is Fork_Test, PermitSignature {
    constructor(IERC20 asset_) Fork_Test(asset_) { }

    struct CreateWithRangeParams {
        uint128 batchSize;
        LockupLinear.Range range;
        address recipient;
        uint128 perStreamAmount;
        uint256 userPrivateKey;
    }

    function testForkFuzz_BatchCreateWithRange(CreateWithRangeParams memory params) external {
        params.batchSize = boundUint128(params.batchSize, 1, 20);
        params.perStreamAmount = boundUint128(params.perStreamAmount, 1, MAX_UINT128 / params.batchSize);
        params.range.start = boundUint40(params.range.start, getBlockTimestamp(), getBlockTimestamp() + 24 hours);
        params.range.cliff = boundUint40(params.range.cliff, params.range.start, params.range.start + 52 weeks);
        params.range.end = boundUint40(params.range.end, params.range.cliff + 1 seconds, MAX_UNIX_TIMESTAMP);
        params.userPrivateKey = boundPrivateKey(params.userPrivateKey);

        address user = vm.addr(params.userPrivateKey);
        IPRBProxy userProxy = loadOrDeployProxy(user);
        checkUsers(user, params.recipient, address(userProxy));

        uint256 firstStreamId = lockupLinear.nextStreamId();
        uint128 totalTransferAmount = params.perStreamAmount * params.batchSize;

        deal({ token: address(asset), to: user, give: uint256(totalTransferAmount) });
        changePrank({ msgSender: user });
        maxApprovePermit2();

        LockupLinear.CreateWithRange memory createParams = LockupLinear.CreateWithRange({
            asset: asset,
            broker: defaults.broker(),
            cancelable: true,
            recipient: params.recipient,
            sender: address(userProxy),
            range: params.range,
            totalAmount: params.perStreamAmount
        });
        Batch.CreateWithRange[] memory batch = BatchBuilder.fillBatch(createParams, params.batchSize);
        Permit2Params memory permit2Params = defaults.permit2Params({
            user: user,
            spender: address(userProxy),
            amount: totalTransferAmount,
            privateKey: params.userPrivateKey
        });
        bytes memory data = abi.encodeCall(target.batchCreateWithRange, (lockupLinear, asset, batch, permit2Params));

        // Asset flow: proxy owner → proxy → Sablier
        // Expect transfers from the proxy owner to the proxy, and then from the proxy to the Sablier contract.
        expectCallToTransferFrom({
            asset_: address(asset),
            from: user,
            to: address(userProxy),
            amount: totalTransferAmount
        });
        expectMultipleCallsToCreateWithRange({ count: uint64(params.batchSize), params: createParams });
        expectMultipleCallsToTransferFrom({
            asset_: address(asset),
            count: uint64(params.batchSize),
            from: address(userProxy),
            to: address(lockupLinear),
            amount: params.perStreamAmount
        });

        bytes memory response = userProxy.execute(address(target), data);
        uint256[] memory actualStreamIds = abi.decode(response, (uint256[]));
        uint256[] memory expectedStreamIds = ArrayBuilder.fillStreamIds(firstStreamId, params.batchSize);
        assertEq(actualStreamIds, expectedStreamIds);
    }

    struct CreateWithMilestonesParams {
        uint128 batchSize;
        address recipient;
        uint128 perStreamAmount;
        uint40 startTime;
        LockupDynamic.Segment[] segments;
        uint256 userPrivateKey;
    }

    function testForkFuzz_BatchCreateWithMilestones(CreateWithMilestonesParams memory params) external {
        vm.assume(params.segments.length != 0);
        params.batchSize = boundUint128(params.batchSize, 1, 20);
        params.startTime = boundUint40(params.startTime, getBlockTimestamp(), getBlockTimestamp() + 24 hours);
        params.userPrivateKey = boundPrivateKey(params.userPrivateKey);
        fuzzSegmentMilestones(params.segments, params.startTime);
        (params.perStreamAmount,) = fuzzDynamicStreamAmounts({
            upperBound: MAX_UINT128 / params.batchSize,
            segments: params.segments,
            protocolFee: defaults.PROTOCOL_FEE(),
            brokerFee: defaults.BROKER_FEE()
        });

        address user = vm.addr(params.userPrivateKey);
        IPRBProxy userProxy = loadOrDeployProxy(user);
        checkUsers(user, params.recipient, address(userProxy));

        uint256 firstStreamId = lockupDynamic.nextStreamId();
        uint128 totalTransferAmount = params.perStreamAmount * params.batchSize;

        deal({ token: address(asset), to: user, give: uint256(totalTransferAmount) });
        changePrank({ msgSender: user });
        maxApprovePermit2();

        LockupDynamic.CreateWithMilestones memory createWithMilestones = LockupDynamic.CreateWithMilestones({
            asset: asset,
            broker: defaults.broker(),
            cancelable: true,
            recipient: params.recipient,
            segments: params.segments,
            sender: address(userProxy),
            startTime: params.startTime,
            totalAmount: params.perStreamAmount
        });
        Batch.CreateWithMilestones[] memory batch = BatchBuilder.fillBatch(createWithMilestones, params.batchSize);
        Permit2Params memory permit2Params = defaults.permit2Params({
            user: user,
            spender: address(userProxy),
            amount: totalTransferAmount,
            privateKey: params.userPrivateKey
        });
        bytes memory data =
            abi.encodeCall(target.batchCreateWithMilestones, (lockupDynamic, asset, batch, permit2Params));

        // Asset flow: proxy owner → proxy → Sablier
        // Expect transfers from the proxy owner to the proxy, and then from the proxy to the Sablier contract.
        expectCallToTransferFrom({
            asset_: address(asset),
            from: user,
            to: address(userProxy),
            amount: totalTransferAmount
        });
        expectMultipleCallsToCreateWithMilestones({ count: uint64(params.batchSize), params: createWithMilestones });
        expectMultipleCallsToTransferFrom({
            asset_: address(asset),
            count: uint64(params.batchSize),
            from: address(userProxy),
            to: address(lockupDynamic),
            amount: params.perStreamAmount
        });

        bytes memory response = userProxy.execute(address(target), data);
        uint256[] memory actualStreamIds = abi.decode(response, (uint256[]));
        uint256[] memory expectedStreamIds = ArrayBuilder.fillStreamIds(firstStreamId, params.batchSize);
        assertEq(actualStreamIds, expectedStreamIds);
    }
}
