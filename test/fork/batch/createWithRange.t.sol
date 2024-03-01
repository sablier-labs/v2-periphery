    // SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { Batch } from "src/types/DataTypes.sol";

import { Fork_Test } from "../Fork.t.sol";
import { ERC20RebasingMock } from "../../mocks/blast/ERC20RebasingMock.sol";
import { ArrayBuilder } from "../../utils/ArrayBuilder.sol";
import { BatchBuilder } from "../../utils/BatchBuilder.sol";

/// @dev Runs against multiple fork assets.
abstract contract CreateWithRange_Batch_Fork_Test is Fork_Test {
    constructor(IERC20 asset_) Fork_Test(asset_) { }

    function setUp() public virtual override {
        Fork_Test.setUp();
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

    function testForkFuzz_CreateWithRange(CreateWithRangeParams memory params) external {
        params.batchSize = boundUint128(params.batchSize, 1, 20);
        params.perStreamAmount = boundUint128(params.perStreamAmount, 1, MAX_UINT128 / params.batchSize);
        params.range.start = boundUint40(params.range.start, getBlockTimestamp(), getBlockTimestamp() + 24 hours);
        params.range.cliff = boundUint40(params.range.cliff, params.range.start, params.range.start + 52 weeks);
        params.range.end = boundUint40(params.range.end, params.range.cliff + 1 seconds, MAX_UNIX_TIMESTAMP);

        checkUsers(params.sender, params.recipient);

        uint256 firstStreamId = lockupLinear.nextStreamId();
        uint128 totalTransferAmount = params.perStreamAmount * params.batchSize;

        // Fund the sender address with rebasing asset.
        changePrank({ msgSender: ERC20RebasingMock(address(ASSET)).bridge() });
        ERC20RebasingMock(address(ASSET)).mint(params.sender, uint256(totalTransferAmount));

        changePrank({ msgSender: params.sender });
        approveContract({ asset_: ASSET, from: params.sender, spender: address(batch) });

        LockupLinear.CreateWithRange memory createParams = LockupLinear.CreateWithRange({
            asset: ASSET,
            broker: defaults.broker(),
            cancelable: true,
            recipient: params.recipient,
            sender: params.sender,
            range: params.range,
            totalAmount: params.perStreamAmount,
            transferable: true
        });
        Batch.CreateWithRange[] memory batchParams = BatchBuilder.fillBatch(createParams, params.batchSize);

        // Asset flow: sender → batch → Sablier
        expectCallToTransferFrom({
            asset_: address(ASSET),
            from: params.sender,
            to: address(batch),
            amount: totalTransferAmount
        });
        expectMultipleCallsToCreateWithRange({ count: uint64(params.batchSize), params: createParams });
        expectMultipleCallsToTransferFrom({
            asset_: address(ASSET),
            count: uint64(params.batchSize),
            from: address(batch),
            to: address(lockupLinear),
            amount: params.perStreamAmount
        });

        uint256[] memory actualStreamIds = batch.createWithRange(lockupLinear, ASSET, batchParams);
        uint256[] memory expectedStreamIds = ArrayBuilder.fillStreamIds(firstStreamId, params.batchSize);
        assertEq(actualStreamIds, expectedStreamIds);
    }
}
