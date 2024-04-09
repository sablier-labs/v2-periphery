// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Errors } from "src/libraries/Errors.sol";
import { Batch } from "src/types/DataTypes.sol";

import { Integration_Test } from "../../Integration.t.sol";

contract CreateWithTimestampsLT_Integration_Test is Integration_Test {
    function setUp() public virtual override {
        Integration_Test.setUp();
    }

    function test_RevertWhen_BatchSizeZero() external {
        Batch.CreateWithTimestampsLT[] memory batchParams = new Batch.CreateWithTimestampsLT[](0);
        vm.expectRevert(Errors.SablierV2Batch_BatchSizeZero.selector);
        batch.createWithTimestampsLT(lockupTranched, dai, batchParams);
    }

    modifier whenBatchSizeNotZero() {
        _;
    }

    function test_BatchCreateWithTimestamps() external whenBatchSizeNotZero {
        // Asset flow: Alice → batch → Sablier
        // Expect transfers from Alice to the batch, and then from the batch to the Sablier contract.
        expectCallToTransferFrom({ from: users.alice, to: address(batch), amount: defaults.TOTAL_TRANSFER_AMOUNT() });
        expectMultipleCallsToCreateWithTimestampsLT({
            count: defaults.BATCH_SIZE(),
            params: defaults.createWithTimestampsLT()
        });
        expectMultipleCallsToTransferFrom({
            count: defaults.BATCH_SIZE(),
            from: address(batch),
            to: address(lockupTranched),
            amount: defaults.PER_STREAM_AMOUNT()
        });

        // Assert that the batch of streams has been created successfully.
        uint256[] memory actualStreamIds =
            batch.createWithTimestampsLT(lockupTranched, dai, defaults.batchCreateWithTimestampsLT());
        uint256[] memory expectedStreamIds = defaults.incrementalStreamIds();
        assertEq(actualStreamIds, expectedStreamIds, "stream ids mismatch");
    }
}
