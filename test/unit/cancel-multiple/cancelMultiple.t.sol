// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ISablierV2Lockup } from "@sablier/v2-core/interfaces/ISablierV2Lockup.sol";
import { Lockup } from "@sablier/v2-core/types/DataTypes.sol";

import { Batch } from "src/types/DataTypes.sol";

import { Base_Test } from "../../Base.t.sol";
import { Defaults } from "../../helpers/Defaults.t.sol";

contract CancelMultiple_Unit_Test is Base_Test {
    function test_CancelMultiple_Linear() internal {
        // Create a batch of streams due to be canceled.
        uint256[] memory streamIds = batchCreateWithRange();

        // Run the test.
        test_CancelMultiple(streamIds, linear);
    }

    function test_CancelMultiple_Dynamic() internal {
        // Create a batch of streams due to be canceled.
        uint256[] memory streamIds = batchCreateWithMilestones();

        // Run the test.
        test_CancelMultiple(streamIds, dynamic);
    }

    function test_CancelMultiple(uint256[] memory streamIds, ISablierV2Lockup lockup) internal {
        // Warp into the future.
        vm.warp(defaults.WARP_26_PERCENT());

        // Asset flow: proxy owner → proxy → sender
        expectMultipleCallsToTransfer({ to: address(proxy), amount: defaults.REFUND_AMOUNT() });
        expectCallToTransfer({ to: users.sender.addr, amount: defaults.REFUND_AMOUNT() * defaults.BATCH_SIZE() });

        bytes memory data = abi.encodeCall(target.cancelMultiple, (lockup, defaults.assets(), streamIds));
        proxy.execute(address(target), data);

        // Assert that all streams have been marked as canceled.
        Lockup.Status expectedStatus = Lockup.Status.CANCELED;
        for (uint256 i = 0; i < defaults.BATCH_SIZE(); ++i) {
            Lockup.Status actualStatus = lockup.getStatus(streamIds[i]);
            assertEq(actualStatus, expectedStatus, "stream status not canceled");
        }
    }
}
