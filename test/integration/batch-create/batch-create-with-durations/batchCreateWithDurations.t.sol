// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Errors } from "src/libraries/Errors.sol";
import { Batch } from "src/types/DataTypes.sol";

import { Integration_Test } from "../../Integration.t.sol";

contract BatchCreateWithDurations_Integration_Test is Integration_Test {
    function setUp() public virtual override { }

    function test_RevertWhen_BatchSizeZero() external {
        Batch.CreateWithDurations[] memory batch = new Batch.CreateWithDurations[](0);
        bytes memory data = abi.encodeCall(target.batchCreateWithDurations, (lockupLinear, asset, batch, bytes("")));
        vm.expectRevert(Errors.SablierV2ProxyTarget_BatchSizeZero.selector);
        aliceProxy.execute(address(target), data);
    }

    modifier whenBatchSizeNotZero() {
        _;
    }

    function test_BatchCreateWithDurations() external whenBatchSizeNotZero {
        // Asset flow: proxy owner → proxy → Sablier
        // Expect transfers from the proxy owner to the proxy, and then from the proxy to the Sablier contract.
        expectCallToTransferFrom({
            from: users.alice.addr,
            to: address(aliceProxy),
            amount: defaults.TOTAL_TRANSFER_AMOUNT()
        });
        expectMultipleCallsToCreateWithDurations({ count: defaults.BATCH_SIZE(), params: defaults.createWithDurations() });
        expectMultipleCallsToTransferFrom({
            count: defaults.BATCH_SIZE(),
            from: address(aliceProxy),
            to: address(lockupLinear),
            amount: defaults.PER_STREAM_AMOUNT()
        });

        // Assert that the batch of streams has been created successfully.
        uint256[] memory actualStreamIds =
            batch.createWithDurations(lockupLinear, asset, defaults.batchCreateWithDurations());
        uint256[] memory expectedStreamIds = defaults.incrementalStreamIds();
        assertEq(actualStreamIds, expectedStreamIds, "stream ids mismatch");
    }
}
