// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Lockup } from "@sablier/v2-core/types/DataTypes.sol";

import { Batch } from "src/types/DataTypes.sol";

import { Base_Test } from "../../Base.t.sol";
import { Defaults } from "../../helpers/Defaults.t.sol";

contract BatchCancelMultiple_Unit_Test is Base_Test {
    function test_BatchCancelMultiple_BatchSizeZero() external {
        Batch.CancelMultiple[] memory params = new Batch.CancelMultiple[](0);
        bytes memory data = abi.encodeCall(target.batchCancelMultiple, (params, Defaults.assets(dai)));
        proxy.execute(address(target), data);
    }

    modifier batchSizeNotZero() {
        _;
    }

    function test_BatchCancelMultiple() external batchSizeNotZero {
        // Create two batches of streams due to be canceled.
        uint256[] memory dynamicStreamIds = batchCreateWithMilestones({ nonce: 0 });
        uint256[] memory linearStreamIds = batchCreateWithRange({ nonce: 1 });

        // Warp into the future.
        vm.warp({ timestamp: Defaults.WARP_26_PERCENT });

        // Expects calls to cancel multiple streams.
        expectCallToCancelMultiple({ lockup: address(dynamic), streamIds: dynamicStreamIds });
        expectCallToCancelMultiple({ lockup: address(linear), streamIds: linearStreamIds });

        // Asset flow: Sablier → proxy → proxy owner
        // Expects transfers from the Sablier contracts to the proxy, and then from the proxy to the proxy owner.
        expectMultipleCallsToTransfer({ to: address(proxy), amount: Defaults.REFUND_AMOUNT });
        expectMultipleCallsToTransfer({ to: address(proxy), amount: Defaults.REFUND_AMOUNT });
        expectCallToTransfer({ to: users.sender.addr, amount: 2 * Defaults.BATCH_SIZE * Defaults.REFUND_AMOUNT });

        // ABI encode the parameters and call the function via the proxy.
        Batch.CancelMultiple[] memory params = new Batch.CancelMultiple[](2);
        params[0] = Batch.CancelMultiple(dynamic, dynamicStreamIds);
        params[1] = Batch.CancelMultiple(linear, linearStreamIds);
        bytes memory data = abi.encodeCall(target.batchCancelMultiple, (params, Defaults.assets(dai)));
        proxy.execute(address(target), data);

        // Assert that all streams have been marked as canceled.
        Lockup.Status expectedStatus = Lockup.Status.CANCELED;
        for (uint256 i = 0; i < Defaults.BATCH_SIZE; ++i) {
            Lockup.Status actualDynamicStatus = dynamic.getStatus(dynamicStreamIds[i]);
            Lockup.Status actualLinearStatus = linear.getStatus(dynamicStreamIds[i]);
            assertEq(actualDynamicStatus, expectedStatus, "dynamic stream status not canceled");
            assertEq(actualLinearStatus, expectedStatus, "linear stream status not canceled");
        }
    }
}
