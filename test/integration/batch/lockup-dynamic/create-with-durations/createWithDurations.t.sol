// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Errors } from "src/libraries/Errors.sol";
import { Batch } from "src/types/DataTypes.sol";

import { Integration_Test } from "../../../Integration.t.sol";

contract CreateWithDurations_LockupDynamic_Integration_Test is Integration_Test {
    function setUp() public virtual override {
        Integration_Test.setUp();
    }

    function test_RevertWhen_BatchSizeZero() external {
        Batch.CreateWithDurationsLD[] memory batchParams = new Batch.CreateWithDurationsLD[](0);
        vm.expectRevert(Errors.SablierV2Batch_BatchSizeZero.selector);
        batch.createWithDurationsLD(lockupDynamic, asset, batchParams);
    }

    modifier whenBatchSizeNotZero() {
        _;
    }

    function test_BatchCreateWithDurations() external whenBatchSizeNotZero {
        // Asset flow: Alice → batch → Sablier
        // Expect transfers from Alice to the batch, and then from the batch to the Sablier contract.
        expectCallToTransferFrom({ from: users.alice, to: address(batch), amount: defaults.TOTAL_TRANSFER_AMOUNT() });
        expectMultipleCallsToCreateWithDurationsLD({
            count: defaults.BATCH_SIZE(),
            params: defaults.createWithDurationsLD()
        });
        expectMultipleCallsToTransferFrom({
            count: defaults.BATCH_SIZE(),
            from: address(batch),
            to: address(lockupDynamic),
            amount: defaults.PER_STREAM_AMOUNT()
        });

        // Assert that the batch of streams has been created successfully.
        uint256[] memory actualStreamIds =
            batch.createWithDurationsLD(lockupDynamic, asset, defaults.batchCreateWithDurationsLD());
        uint256[] memory expectedStreamIds = defaults.incrementalStreamIds();
        assertEq(actualStreamIds, expectedStreamIds, "stream ids mismatch");
    }
}