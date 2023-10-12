// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Errors } from "src/libraries/Errors.sol";
import { Batch } from "src/types/DataTypes.sol";

import { Target_Integration_Test } from "../Target.t.sol";

abstract contract BatchCreateWithRange_Integration_Test is Target_Integration_Test {
    function setUp() public virtual override { }

    function test_RevertWhen_NotDelegateCalled() external {
        Batch.CreateWithRange[] memory batchParams;
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        target.batchCreateWithRange({
            lockupLinear: lockupLinear,
            asset: asset,
            batch: batchParams,
            transferData: bytes("")
        });
    }

    modifier whenDelegateCalled() {
        _;
    }

    function test_RevertWhen_BatchSizeZero() external whenDelegateCalled {
        Batch.CreateWithRange[] memory batchParams = new Batch.CreateWithRange[](0);
        bytes memory data = abi.encodeCall(target.batchCreateWithRange, (lockupLinear, asset, batchParams, bytes("")));
        vm.expectRevert(Errors.SablierV2ProxyTarget_BatchSizeZero.selector);
        aliceProxy.execute(address(target), data);
    }

    modifier whenBatchSizeNotZero() {
        _;
    }

    function test_BatchCreateWithRange() external whenBatchSizeNotZero whenDelegateCalled {
        // Asset flow: proxy owner → proxy → Sablier
        // Expect transfers from the proxy owner to the proxy, and then from the proxy to the Sablier contract.
        expectCallToTransferFrom({
            from: users.alice.addr,
            to: address(aliceProxy),
            amount: defaults.TOTAL_TRANSFER_AMOUNT()
        });
        expectMultipleCallsToCreateWithRange({ count: defaults.BATCH_SIZE(), params: defaults.createWithRange() });
        expectMultipleCallsToTransferFrom({
            count: defaults.BATCH_SIZE(),
            from: address(aliceProxy),
            to: address(lockupLinear),
            amount: defaults.PER_STREAM_AMOUNT()
        });

        // Assert that the batch of streams has been created successfully.
        uint256[] memory actualStreamIds = batchCreateWithRange();
        uint256[] memory expectedStreamIds = defaults.incrementalStreamIds();
        assertEq(actualStreamIds, expectedStreamIds, "stream ids mismatch");
    }
}
