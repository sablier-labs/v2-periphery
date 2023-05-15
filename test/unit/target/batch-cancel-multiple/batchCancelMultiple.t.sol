// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { Lockup } from "@sablier/v2-core/types/DataTypes.sol";

import { Errors } from "src/libraries/Errors.sol";
import { Batch } from "src/types/DataTypes.sol";

import { Unit_Test } from "../../Unit.t.sol";

contract BatchCancelMultiple_Unit_Test is Unit_Test {
    function test_RevertWhen_CallNotDelegateCall() external {
        Batch.CancelMultiple[] memory batch;
        IERC20[] memory assets = defaults.assets();
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        target.batchCancelMultiple(batch, assets);
    }

    modifier whenDelegateCall() {
        _;
    }

    function test_RevertWhen_BatchSizeZero() external whenDelegateCall {
        Batch.CancelMultiple[] memory batch = new Batch.CancelMultiple[](0);
        bytes memory data = abi.encodeCall(target.batchCancelMultiple, (batch, defaults.assets()));
        vm.expectRevert(Errors.SablierV2ProxyTarget_BatchSizeZero.selector);
        proxy.execute(address(target), data);
    }

    modifier batchSizeNotZero() {
        _;
    }

    function test_BatchCancelMultiple() external batchSizeNotZero whenDelegateCall {
        // Create two batches of streams due to be canceled.
        uint256[] memory dynamicStreamIds = batchCreateWithMilestones();
        uint256[] memory linearStreamIds = batchCreateWithRange();

        // Simulate the passage of time.
        vm.warp({ timestamp: defaults.CLIFF_TIME() });

        // Expects calls to cancel multiple streams.
        expectCallToCancelMultiple({ lockup: dynamic, streamIds: dynamicStreamIds });
        expectCallToCancelMultiple({ lockup: linear, streamIds: linearStreamIds });

        // Asset flow: Sablier → proxy → proxy owner
        // Expects transfers from the Sablier contracts to the proxy, and then from the proxy to the proxy owner.
        expectMultipleCallsToTransfer({
            count: 2 * defaults.BATCH_SIZE(),
            to: address(proxy),
            amount: defaults.REFUND_AMOUNT()
        });
        expectCallToTransfer({ to: users.alice.addr, amount: 2 * defaults.REFUND_AMOUNT() * defaults.BATCH_SIZE() });

        // ABI encode the parameters and call the function via the proxy.
        Batch.CancelMultiple[] memory batch = new Batch.CancelMultiple[](2);
        batch[0] = Batch.CancelMultiple(dynamic, dynamicStreamIds);
        batch[1] = Batch.CancelMultiple(linear, linearStreamIds);
        bytes memory data = abi.encodeCall(target.batchCancelMultiple, (batch, defaults.assets()));
        proxy.execute(address(target), data);

        // Assert that all streams have been marked as canceled.
        Lockup.Status expectedStatus = Lockup.Status.CANCELED;
        for (uint256 i = 0; i < defaults.BATCH_SIZE(); ++i) {
            Lockup.Status actualDynamicStatus = dynamic.getStatus(dynamicStreamIds[i]);
            Lockup.Status actualLinearStatus = linear.getStatus(linearStreamIds[i]);
            assertEq(actualDynamicStatus, expectedStatus, "dynamic stream status not canceled");
            assertEq(actualLinearStatus, expectedStatus, "linear stream status not canceled");
        }
    }
}
