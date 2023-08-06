// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Errors } from "src/libraries/Errors.sol";
import { Batch } from "src/types/DataTypes.sol";
import { Permit2Params } from "src/types/Permit2.sol";

import { Integration_Test } from "../../../Integration.t.sol";

abstract contract BatchCreateWithDeltas_Integration_Test is Integration_Test {
    function setUp() public virtual override {
        Integration_Test.setUp();
    }

    function test_RevertWhen_NotDelegateCalled() external {
        Batch.CreateWithDeltas[] memory batch;
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        target.batchCreateWithDeltas(lockupDynamic, asset, batch, "");
    }

    modifier whenDelegateCalled() {
        _;
    }

    function test_RevertWhen_BatchSizeZero() external whenDelegateCalled {
        Batch.CreateWithDeltas[] memory batch = new Batch.CreateWithDeltas[](0);
        bytes memory data = abi.encodeCall(target.batchCreateWithDeltas, (lockupDynamic, asset, batch, ""));
        vm.expectRevert(Errors.SablierV2ProxyTarget_BatchSizeZero.selector);
        aliceProxy.execute(address(target), data);
    }

    modifier whenBatchSizeNotZero() {
        _;
    }

    function test_BatchCreateWithDeltas() external whenBatchSizeNotZero whenDelegateCalled {
        // Asset flow: proxy owner → proxy → Sablier
        // Expect transfers from the proxy owner to the proxy, and then from the proxy to the Sablier contract.
        expectCallToTransferFrom({
            from: users.alice.addr,
            to: address(aliceProxy),
            amount: defaults.TOTAL_TRANSFER_AMOUNT()
        });
        expectMultipleCallsToCreateWithDeltas({ count: defaults.BATCH_SIZE(), params: defaults.createWithDeltas() });
        expectMultipleCallsToTransferFrom({
            count: defaults.BATCH_SIZE(),
            from: address(aliceProxy),
            to: address(lockupDynamic),
            amount: defaults.PER_STREAM_AMOUNT()
        });

        // Assert that the batch of streams has been created successfully.
        uint256[] memory actualStreamIds = batchCreateWithDeltas();
        uint256[] memory expectedStreamIds = defaults.incrementalStreamIds();
        assertEq(actualStreamIds, expectedStreamIds, "stream ids mismatch");
    }
}
