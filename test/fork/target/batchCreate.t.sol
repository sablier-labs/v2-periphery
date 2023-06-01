// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IPRBProxy } from "@prb/proxy/interfaces/IPRBProxy.sol";
import { LockupDynamic, LockupLinear } from "@sablier/v2-core/types/DataTypes.sol";
import { IAllowanceTransfer } from "permit2/interfaces/IAllowanceTransfer.sol";

import { PermitSignature } from "permit2-test/utils/PermitSignature.sol";

import { Batch, Permit2Params } from "src/types/DataTypes.sol";

import { Fork_Test } from "../Fork.t.sol";
import { ArrayBuilder } from "../../utils/ArrayBuilder.sol";
import { ParamsBuilder } from "../../utils/ParamsBuilder.sol";

/// @dev Runs against multiple assets.
abstract contract BatchCreate_Fork_Test is Fork_Test, PermitSignature {
    constructor(IERC20 asset_) Fork_Test(asset_) { }

    function preparePermit2Params(
        address user,
        address spender,
        uint160 amount,
        uint256 privateKey
    )
        internal
        view
        returns (Permit2Params memory permit2Params)
    {
        (,, uint48 nonce) = permit2.allowance({ user: user, token: address(asset), spender: spender });
        IAllowanceTransfer.PermitSingle memory permitSingle = IAllowanceTransfer.PermitSingle({
            details: IAllowanceTransfer.PermitDetails({
                amount: amount,
                expiration: defaults.PERMIT2_EXPIRATION(),
                nonce: nonce,
                token: address(asset)
            }),
            sigDeadline: defaults.PERMIT2_SIG_DEADLINE(),
            spender: spender
        });
        permit2Params = Permit2Params({
            permit2: permit2,
            permitSingle: permitSingle,
            signature: getPermitSignature({
                permit: permitSingle,
                privateKey: privateKey,
                domainSeparator: permit2.DOMAIN_SEPARATOR()
            })
        });
    }

    struct CreateWithRangeParams {
        uint128 batchSize;
        LockupLinear.Range range;
        address recipient;
        uint128 perStreamAmount;
        uint256 senderPrivateKey;
    }

    function testForkFuzz_BatchCreateWithRange(CreateWithRangeParams memory params) external {
        params.batchSize = boundUint128(params.batchSize, 1, 20);
        params.perStreamAmount = boundUint128(params.perStreamAmount, 1, MAX_UINT128 / params.batchSize);
        params.range.start = boundUint40(params.range.start, getBlockTimestamp(), getBlockTimestamp() + 24 hours);
        params.range.cliff = boundUint40(params.range.cliff, params.range.start, params.range.start + 52 weeks);
        params.range.end = boundUint40(params.range.end, params.range.cliff + 1 seconds, MAX_UNIX_TIMESTAMP);
        params.senderPrivateKey = boundPrivateKey(params.senderPrivateKey);

        address sender = vm.addr(params.senderPrivateKey);
        IPRBProxy senderProxy = loadOrDeployProxy(sender);
        checkUsers(sender, params.recipient, address(senderProxy));

        uint256 firstStreamId = lockupLinear.nextStreamId();
        uint128 totalTransferAmount = params.perStreamAmount * params.batchSize;

        deal({ token: address(asset), to: sender, give: uint256(totalTransferAmount) });
        changePrank({ msgSender: sender });
        maxApprovePermit2();

        Batch.CreateWithRange memory batchSingle = Batch.CreateWithRange({
            broker: defaults.broker(),
            cancelable: true,
            recipient: params.recipient,
            sender: address(senderProxy),
            range: params.range,
            totalAmount: params.perStreamAmount
        });
        Batch.CreateWithRange[] memory batch = ArrayBuilder.fillBatch(batchSingle, params.batchSize);
        Permit2Params memory permit2Params = preparePermit2Params({
            user: sender,
            spender: address(senderProxy),
            amount: totalTransferAmount,
            privateKey: params.senderPrivateKey
        });
        bytes memory data = abi.encodeCall(target.batchCreateWithRange, (lockupLinear, asset, batch, permit2Params));

        // Asset flow: proxy owner → proxy → Sablier
        // Expect transfers from the proxy owner to the proxy, and then from the proxy to the Sablier contract.
        expectCallToTransferFrom({
            asset_: address(asset),
            from: sender,
            to: address(senderProxy),
            amount: totalTransferAmount
        });
        expectMultipleCallsToCreateWithRange({
            count: uint64(params.batchSize),
            params: ParamsBuilder.createWithRange(batchSingle, asset)
        });
        expectMultipleCallsToTransferFrom({
            asset_: address(asset),
            count: uint64(params.batchSize),
            from: address(senderProxy),
            to: address(lockupLinear),
            amount: params.perStreamAmount
        });

        bytes memory response = senderProxy.execute(address(target), data);
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
        uint256 senderPrivateKey;
    }

    function testForkFuzz_BatchCreateWithMilestones(CreateWithMilestonesParams memory params) private {
        vm.assume(params.segments.length != 0);
        params.batchSize = boundUint128(params.batchSize, 1, 1);
        params.startTime = boundUint40(params.startTime, getBlockTimestamp(), getBlockTimestamp() + 24 hours);
        params.senderPrivateKey = boundPrivateKey(params.senderPrivateKey);
        fuzzSegmentMilestones(params.segments, params.startTime);
        (params.perStreamAmount,) = fuzzDynamicStreamAmounts({
            upperBound: MAX_UINT128 / params.batchSize,
            segments: params.segments,
            protocolFee: defaults.PROTOCOL_FEE(),
            brokerFee: defaults.BROKER_FEE()
        });

        address sender = vm.addr(params.senderPrivateKey);
        IPRBProxy senderProxy = loadOrDeployProxy(sender);
        checkUsers(sender, params.recipient, address(senderProxy));

        uint256 firstStreamId = lockupDynamic.nextStreamId();
        uint128 totalTransferAmount = params.perStreamAmount * params.batchSize;

        deal({ token: address(asset), to: sender, give: uint256(totalTransferAmount) });
        changePrank({ msgSender: sender });
        maxApprovePermit2();

        Batch.CreateWithMilestones memory batchSingle = Batch.CreateWithMilestones({
            broker: defaults.broker(),
            cancelable: true,
            recipient: params.recipient,
            segments: params.segments,
            sender: address(senderProxy),
            startTime: params.startTime,
            totalAmount: params.perStreamAmount
        });
        Batch.CreateWithMilestones[] memory batch = ArrayBuilder.fillBatch(batchSingle, params.batchSize);
        Permit2Params memory permit2Params = preparePermit2Params({
            user: sender,
            spender: address(senderProxy),
            amount: totalTransferAmount,
            privateKey: params.senderPrivateKey
        });
        bytes memory data =
            abi.encodeCall(target.batchCreateWithMilestones, (lockupDynamic, asset, batch, permit2Params));

        // Asset flow: proxy owner → proxy → Sablier
        // Expect transfers from the proxy owner to the proxy, and then from the proxy to the Sablier contract.
        expectCallToTransferFrom({
            asset_: address(asset),
            from: sender,
            to: address(senderProxy),
            amount: totalTransferAmount
        });
        expectMultipleCallsToCreateWithMilestones({
            count: uint64(params.batchSize),
            params: ParamsBuilder.createWithMilestones(batchSingle, asset)
        });
        expectMultipleCallsToTransferFrom({
            asset_: address(asset),
            count: uint64(params.batchSize),
            from: address(senderProxy),
            to: address(lockupDynamic),
            amount: params.perStreamAmount
        });

        bytes memory response = senderProxy.execute(address(target), data);
        uint256[] memory actualStreamIds = abi.decode(response, (uint256[]));
        uint256[] memory expectedStreamIds = ArrayBuilder.fillStreamIds(firstStreamId, params.batchSize);
        assertEq(actualStreamIds, expectedStreamIds);
    }
}
