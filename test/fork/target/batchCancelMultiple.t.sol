// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Lockup } from "@sablier/v2-core/src/types/DataTypes.sol";

import { Batch } from "src/types/DataTypes.sol";

import { Fork_Test } from "../Fork.t.sol";

/// @dev Runs against multiple fork assets.
abstract contract BatchCancelMultiple_Fork_Test is Fork_Test {
    constructor(IERC20 asset_) Fork_Test(asset_) { }

    function setUp() public virtual override { }

    function testForkFuzz_BatchCancelMultiple(uint256 batchSize) external {
        batchSize = _bound(batchSize, 1, 50);

        // Create two batches of streams.
        uint256[] memory dynamicStreamIds = batchCreateWithMilestones(batchSize);
        uint256[] memory linearStreamIds = batchCreateWithRange(batchSize);

        // Simulate the passage of time.
        vm.warp({ timestamp: defaults.CLIFF_TIME() });

        // Expects calls to cancel multiple streams.
        expectCallToCancelMultiple({ lockup: lockupDynamic, streamIds: dynamicStreamIds });
        expectCallToCancelMultiple({ lockup: lockupLinear, streamIds: linearStreamIds });

        // Asset flow: Sablier → proxy → proxy owner
        // Expects transfers from the Sablier contracts to the proxy, and then from the proxy to the proxy owner.
        uint256 totalTransferAmount = 2 * defaults.REFUND_AMOUNT() * batchSize;
        expectMultipleCallsToTransfer({
            count: uint64(2 * batchSize),
            to: address(aliceProxy),
            amount: defaults.REFUND_AMOUNT()
        });
        expectCallToTransfer({ to: users.alice.addr, amount: totalTransferAmount });

        // ABI encode the parameters and call the function via the proxy.
        Batch.CancelMultiple[] memory batch = new Batch.CancelMultiple[](2);
        batch[0] = Batch.CancelMultiple(lockupDynamic, dynamicStreamIds);
        batch[1] = Batch.CancelMultiple(lockupLinear, linearStreamIds);
        bytes memory data = abi.encodeCall(target.batchCancelMultiple, (batch, defaults.assets()));
        aliceProxy.execute(address(target), data);

        // Assert that all streams have been canceled.
        Lockup.Status expectedStatus = Lockup.Status.CANCELED;
        for (uint256 i = 0; i < batchSize; ++i) {
            Lockup.Status actualDynamicStatus = lockupDynamic.statusOf(dynamicStreamIds[i]);
            Lockup.Status actualLinearStatus = lockupLinear.statusOf(linearStreamIds[i]);
            assertEq(actualDynamicStatus, expectedStatus, "lockupDynamic stream status not canceled");
            assertEq(actualLinearStatus, expectedStatus, "lockupLinear stream status not canceled");
        }
    }
}
