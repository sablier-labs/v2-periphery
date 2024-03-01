    // SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { BatchLockup } from "src/types/DataTypes.sol";

import { ERC20RebasingMock } from "../../mocks/blast/ERC20RebasingMock.sol";
import { ArrayBuilder } from "../../utils/ArrayBuilder.sol";
import { BatchLockupBuilder } from "../../utils/BatchLockupBuilder.sol";
import { Fork_Test } from "../Fork.t.sol";

/// @dev Runs against multiple fork assets.
abstract contract CreateWithTimestamps_LockupLinear_BatchLockup_Fork_Test is Fork_Test {
    constructor(IERC20 asset_) Fork_Test(asset_) { }

    function setUp() public virtual override {
        Fork_Test.setUp();
    }

    struct CreateWithTimestampsParams {
        uint128 batchSize;
        LockupLinear.Range range;
        address sender;
        address recipient;
        uint128 perStreamAmount;
    }

    function testForkFuzz_CreateWithTimestampsLL(CreateWithTimestampsParams memory params) external {
        params.batchSize = boundUint128(params.batchSize, 1, 20);
        params.perStreamAmount = boundUint128(params.perStreamAmount, 1, MAX_UINT128 / params.batchSize);
        params.range.start = boundUint40(params.range.start, getBlockTimestamp(), getBlockTimestamp() + 24 hours);
        params.range.cliff =
            boundUint40(params.range.cliff, params.range.start + 1 seconds, params.range.start + 52 weeks);
        params.range.end = boundUint40(params.range.end, params.range.cliff + 1 seconds, MAX_UNIX_TIMESTAMP);

        checkUsers(params.sender, params.recipient);

        uint256 firstStreamId = lockupLinear.nextStreamId();
        uint128 totalTransferAmount = params.perStreamAmount * params.batchSize;

        // Fund the sender address with rebasing asset.
        resetPrank({ msgSender: ERC20RebasingMock(address(FORK_ASSET)).bridge() });
        ERC20RebasingMock(address(FORK_ASSET)).mint(params.sender, uint256(totalTransferAmount));

        resetPrank({ msgSender: params.sender });
        approveContract({ asset_: FORK_ASSET, from: params.sender, spender: address(batchLockup) });

        LockupLinear.CreateWithTimestamps memory createParams = LockupLinear.CreateWithTimestamps({
            sender: params.sender,
            recipient: params.recipient,
            totalAmount: params.perStreamAmount,
            asset: FORK_ASSET,
            cancelable: true,
            transferable: true,
            range: params.range,
            broker: defaults.broker()
        });
        BatchLockup.CreateWithTimestampsLL[] memory batchParams =
            BatchLockupBuilder.fillBatch(createParams, params.batchSize);

        // Asset flow: sender → batch → Sablier
        expectCallToTransferFrom({
            asset_: address(FORK_ASSET),
            from: params.sender,
            to: address(batchLockup),
            amount: totalTransferAmount
        });
        expectMultipleCallsToCreateWithTimestampsLL({ count: uint64(params.batchSize), params: createParams });
        expectMultipleCallsToTransferFrom({
            asset_: address(FORK_ASSET),
            count: uint64(params.batchSize),
            from: address(batchLockup),
            to: address(lockupLinear),
            amount: params.perStreamAmount
        });

        uint256[] memory actualStreamIds = batchLockup.createWithTimestampsLL(lockupLinear, FORK_ASSET, batchParams);
        uint256[] memory expectedStreamIds = ArrayBuilder.fillStreamIds(firstStreamId, params.batchSize);
        assertEq(actualStreamIds, expectedStreamIds);
    }
}
