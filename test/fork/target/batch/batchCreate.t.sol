// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { IPRBProxy } from "@prb/proxy/interfaces/IPRBProxy.sol";
import { Fuzzers } from "@sablier/v2-core-test/utils/Fuzzers.sol";
import { IAllowanceTransfer } from "permit2/interfaces/IAllowanceTransfer.sol";
import { PermitSignature } from "permit2-test/utils/PermitSignature.sol";

import { Batch, LockupDynamic, LockupLinear, Permit2Params } from "src/types/DataTypes.sol";

import { Fork_Test } from "../../Fork.t.sol";

abstract contract BatchCreate_Fork_Test is Fork_Test, Fuzzers, PermitSignature {
    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Runs against multiple assets.
    constructor(IERC20 asset_) Fork_Test(asset_) { }

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    struct Params {
        uint64 batchSize;
        LockupLinear.Range range;
        address recipient;
        uint256 userPrivateKey;
        uint128 linearPerStreamAmount;
        LockupDynamic.Segment[] segments;
    }

    struct Vars {
        address user;
        IPRBProxy proxy;
        uint128 upperBoundPerStreamAmount;
        Permit2Params permit2Params;
        // Batch create dynamic vars
        uint128 dynamicPerStreamAmount;
        uint128 dynamicTransferAmount;
        uint256 beforeBatchDynamicNextStreamId;
        Batch.CreateWithMilestones batchDynamicSingle;
        LockupDynamic.CreateWithMilestones dynamicParams;
        bytes dynamicData;
        bytes dynamicResponse;
        uint256[] actualDynamicStreamIds;
        uint256[] expectedDynamicStreamIds;
        // Batch create linear vars
        uint128 linearTransferAmount;
        uint256 beforeBatchLinearNextStreamId;
        Batch.CreateWithRange batchLinearSingle;
        LockupLinear.CreateWithRange linearParams;
        bytes linearData;
        bytes linearResponse;
        uint256[] actualLinearStreamIds;
        uint256[] expectedLinearStreamIds;
    }

    function testForkFuzz_BatchCreate(Params memory params) external {
        Vars memory vars;
        params.userPrivateKey = boundPrivateKey(params.userPrivateKey);
        vars.user = vm.addr(params.userPrivateKey);
        vars.proxy = proxyRegistry.deployFor(vars.user);

        checkUsers(vars.user, params.recipient, address(vars.proxy));
        vm.assume(params.segments.length != 0);
        params.batchSize = uint64(bound(params.batchSize, 1, 20));

        // Fuzz the per stream amount so that the overall transfer amount stays below 2^128 - 1. Considering
        // that there will be `batchSize` streams created, we need to divide by the batch size.
        vars.upperBoundPerStreamAmount = (MAX_UINT128 - 1) / params.batchSize;
        params.linearPerStreamAmount =
            boundUint128(params.linearPerStreamAmount, 1e18, vars.upperBoundPerStreamAmount - 1);

        (vars.dynamicPerStreamAmount,) = fuzzDynamicStreamAmounts({
            upperBound: vars.upperBoundPerStreamAmount,
            segments: params.segments,
            protocolFee: defaults.PROTOCOL_FEE(),
            brokerFee: defaults.BROKER_FEE()
        });

        uint40 currentTime = getBlockTimestamp();

        // We will use `params.range.start` to represent both dynamic and linear start times.
        params.range.start = boundUint40(params.range.start, currentTime, currentTime + 10_000 seconds);

        // Fuzz the dynamic segment milestones.
        fuzzSegmentMilestones(params.segments, params.range.start);

        // Fuzz the linear range.
        params.range.cliff = boundUint40(params.range.cliff, params.range.start, params.range.start + 52 weeks);
        params.range.end = boundUint40(params.range.end, params.range.cliff + 1, MAX_UNIX_TIMESTAMP);

        // Calculate the transfer amount for the dynamic and linear streams.
        vars.dynamicTransferAmount = vars.dynamicPerStreamAmount * params.batchSize;
        vars.linearTransferAmount = params.linearPerStreamAmount * params.batchSize;

        // Explicitly cast the amounts to `uint256` to prevent potential overflow when adding
        // `vars.dynamicTransferAmount` and `vars.linearTransferAmount`.
        deal({
            token: address(asset),
            to: vars.user,
            give: uint256(vars.dynamicTransferAmount) + uint256(vars.linearTransferAmount)
        });

        vm.startPrank(vars.user);

        // Approve {Permit2} to transfer the user's assets.
        // We use a low-level call to ignore reverts because the asset can have the missing return value bug.
        (bool success,) = address(asset).call(abi.encodeCall(IERC20.approve, (address(permit2), MAX_UINT256)));
        success;

        vars.beforeBatchDynamicNextStreamId = dynamic.nextStreamId();
        vars.beforeBatchLinearNextStreamId = linear.nextStreamId();
        vars.actualDynamicStreamIds = new uint256[](params.batchSize);
        vars.expectedDynamicStreamIds = new uint256[](params.batchSize);

        /*//////////////////////////////////////////////////////////////////////////
                                DYNAMIC BATCH CREATE
        //////////////////////////////////////////////////////////////////////////*/

        vars.batchDynamicSingle = Batch.CreateWithMilestones({
            broker: defaults.broker(),
            cancelable: true,
            recipient: params.recipient,
            segments: params.segments,
            sender: address(vars.proxy),
            startTime: params.range.start,
            totalAmount: vars.dynamicPerStreamAmount
        });
        vars.dynamicParams = getCreateWithMilestoneParams(vars.batchDynamicSingle);
        vars.dynamicData = getBatchWithMilestonesData({
            batchSingle: vars.batchDynamicSingle,
            permit2Params: getPermit2Params({
                user: vars.user,
                proxy_: address(vars.proxy),
                amount: vars.dynamicTransferAmount,
                privateKey: params.userPrivateKey
            }),
            batchSize: params.batchSize
        });

        // Asset flow: proxy owner → proxy → Sablier
        // Expect transfers from the proxy owner to the proxy, and then from the proxy to the Sablier contract.
        expectCallToTransferFrom({
            asset: address(asset),
            from: vars.user,
            to: address(vars.proxy),
            amount: vars.dynamicTransferAmount
        });
        expectMultipleCallsToCreateWithMilestones({ count: params.batchSize, params: vars.dynamicParams });
        expectMultipleCallsToTransferFrom({
            asset: address(asset),
            count: params.batchSize,
            from: address(vars.proxy),
            to: address(dynamic),
            amount: vars.dynamicPerStreamAmount
        });

        vars.dynamicResponse = vars.proxy.execute(address(target), vars.dynamicData);
        vars.actualDynamicStreamIds = abi.decode(vars.dynamicResponse, (uint256[]));
        vars.expectedDynamicStreamIds = getExpectedStreamIds(vars.beforeBatchDynamicNextStreamId, params.batchSize);
        assertEq(vars.actualDynamicStreamIds, vars.expectedDynamicStreamIds);

        /*//////////////////////////////////////////////////////////////////////////
                                LINEAR BATCH CREATE
        //////////////////////////////////////////////////////////////////////////*/

        vars.batchLinearSingle = Batch.CreateWithRange({
            broker: defaults.broker(),
            cancelable: true,
            recipient: params.recipient,
            sender: address(vars.proxy),
            range: params.range,
            totalAmount: params.linearPerStreamAmount
        });
        vars.linearParams = getCreateWithRangeParams(vars.batchLinearSingle);
        vars.linearData = getBatchWithRangeData({
            batchSingle: vars.batchLinearSingle,
            permit2Params: getPermit2Params({
                user: vars.user,
                proxy_: address(vars.proxy),
                amount: vars.linearTransferAmount,
                privateKey: params.userPrivateKey
            }),
            batchSize: params.batchSize
        });

        // Asset flow: proxy owner → proxy → Sablier
        // Expect transfers from the proxy owner to the proxy, and then from the proxy to the Sablier contract.
        expectCallToTransferFrom({
            asset: address(asset),
            from: vars.user,
            to: address(vars.proxy),
            amount: vars.linearTransferAmount
        });
        expectMultipleCallsToCreateWithRange({ count: params.batchSize, params: vars.linearParams });
        expectMultipleCallsToTransferFrom({
            asset: address(asset),
            count: params.batchSize,
            from: address(vars.proxy),
            to: address(linear),
            amount: params.linearPerStreamAmount
        });

        vars.linearResponse = vars.proxy.execute(address(target), vars.linearData);
        vars.actualLinearStreamIds = abi.decode(vars.linearResponse, (uint256[]));
        vars.expectedLinearStreamIds = getExpectedStreamIds(vars.beforeBatchLinearNextStreamId, params.batchSize);
        assertEq(vars.actualLinearStreamIds, vars.expectedLinearStreamIds);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev ABI encode the parameters and return the data.
    function getBatchWithMilestonesData(
        Batch.CreateWithMilestones memory batchSingle,
        Permit2Params memory permit2Params,
        uint256 batchSize
    )
        internal
        view
        returns (bytes memory data)
    {
        Batch.CreateWithMilestones[] memory batch = new Batch.CreateWithMilestones[](batchSize);

        for (uint256 i = 0; i < batchSize; ++i) {
            batch[i] = batchSingle;
        }

        data = abi.encodeCall(target.batchCreateWithMilestones, (dynamic, asset, batch, permit2Params));
    }

    /// @dev ABI encode the parameters and return the data.
    function getBatchWithRangeData(
        Batch.CreateWithRange memory batchSingle,
        Permit2Params memory permit2Params,
        uint256 batchSize
    )
        internal
        view
        returns (bytes memory data)
    {
        Batch.CreateWithRange[] memory batch = new Batch.CreateWithRange[](batchSize);

        for (uint256 i = 0; i < batchSize; ++i) {
            batch[i] = batchSingle;
        }

        data = abi.encodeCall(target.batchCreateWithRange, (linear, asset, batch, permit2Params));
    }

    ///@dev Return the paramaters used in the {SablierV2LockupDynamic.createWithMilestones} function.
    function getCreateWithMilestoneParams(Batch.CreateWithMilestones memory batchSingle)
        internal
        view
        returns (LockupDynamic.CreateWithMilestones memory params)
    {
        params = LockupDynamic.CreateWithMilestones({
            asset: asset,
            broker: batchSingle.broker,
            cancelable: batchSingle.cancelable,
            recipient: batchSingle.recipient,
            sender: batchSingle.sender,
            segments: batchSingle.segments,
            startTime: batchSingle.startTime,
            totalAmount: batchSingle.totalAmount
        });
    }

    ///@dev Return the paramaters used in the {SablierV2LockupLinear.createWithRange} function.
    function getCreateWithRangeParams(Batch.CreateWithRange memory batchSingle)
        internal
        view
        returns (LockupLinear.CreateWithRange memory params)
    {
        params = LockupLinear.CreateWithRange({
            asset: asset,
            broker: batchSingle.broker,
            cancelable: batchSingle.cancelable,
            recipient: batchSingle.recipient,
            sender: batchSingle.sender,
            range: batchSingle.range,
            totalAmount: batchSingle.totalAmount
        });
    }

    /// @dev Return the expected stream ids.
    function getExpectedStreamIds(
        uint256 beforeNextStreamId,
        uint256 batchSize
    )
        internal
        pure
        returns (uint256[] memory streamIds)
    {
        streamIds = new uint256[](batchSize);
        for (uint256 i = 0; i < batchSize; ++i) {
            streamIds[i] = beforeNextStreamId + i;
        }
    }

    function getPermit2Params(
        address user,
        address proxy_,
        uint160 amount,
        uint256 privateKey
    )
        internal
        view
        returns (Permit2Params memory permit2Params)
    {
        (,, uint48 nonce) = permit2.allowance({ user: user, token: address(asset), spender: proxy_ });
        IAllowanceTransfer.PermitSingle memory permitSingle = IAllowanceTransfer.PermitSingle({
            details: IAllowanceTransfer.PermitDetails({
                amount: amount,
                expiration: defaults.PERMIT2_EXPIRATION(),
                nonce: nonce,
                token: address(asset)
            }),
            sigDeadline: defaults.PERMIT2_SIG_DEADLINE(),
            spender: proxy_
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
}
