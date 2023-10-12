// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Errors } from "src/libraries/Errors.sol";
import { Batch } from "src/types/DataTypes.sol";

import { Target_Integration_Test } from "../Target.t.sol";

abstract contract BatchCreateWithMilestones_Integration_Test is Target_Integration_Test {
    function setUp() public virtual override { }

    function test_RevertWhen_NotDelegateCalled() external {
        Batch.CreateWithMilestones[] memory batchParams;
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        target.batchCreateWithMilestones({
            lockupDynamic: lockupDynamic,
            asset: asset,
            batch: batchParams,
            transferData: bytes("")
        });
    }

    modifier whenDelegateCalled() {
        _;
    }

    function test_RevertWhen_BatchSizeZero() external whenDelegateCalled {
        Batch.CreateWithMilestones[] memory batchParams = new Batch.CreateWithMilestones[](0);
        bytes memory data =
            abi.encodeCall(target.batchCreateWithMilestones, (lockupDynamic, asset, batchParams, bytes("")));
        vm.expectRevert(Errors.SablierV2ProxyTarget_BatchSizeZero.selector);
        aliceProxy.execute(address(target), data);
    }

    modifier whenBatchSizeNotZero() {
        _;
    }

    function test_BatchCreateWithMilestones() external whenBatchSizeNotZero whenDelegateCalled {
        // Asset flow: proxy owner → proxy → Sablier
        // Expect transfers from the proxy owner to the proxy, and then from the proxy to the Sablier contract.
        expectCallToTransferFrom({
            from: users.alice.addr,
            to: address(aliceProxy),
            amount: defaults.TOTAL_TRANSFER_AMOUNT()
        });
        expectMultipleCallsToCreateWithMilestones({
            count: defaults.BATCH_SIZE(),
            params: defaults.createWithMilestones()
        });
        expectMultipleCallsToTransferFrom({
            count: defaults.BATCH_SIZE(),
            from: address(aliceProxy),
            to: address(lockupDynamic),
            amount: defaults.PER_STREAM_AMOUNT()
        });

        // Assert that the batch of streams has been created successfully.
        uint256[] memory actualStreamIds = batchCreateWithMilestones();
        uint256[] memory expectedStreamIds = defaults.incrementalStreamIds();
        assertEq(actualStreamIds, expectedStreamIds, "stream ids mismatch");
    }
}
