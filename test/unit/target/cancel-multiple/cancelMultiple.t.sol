// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { ISablierV2Lockup } from "@sablier/v2-core/interfaces/ISablierV2Lockup.sol";
import { Lockup } from "@sablier/v2-core/types/DataTypes.sol";

import { Errors } from "src/libraries/Errors.sol";
import { Batch } from "src/types/DataTypes.sol";

import { Unit_Test } from "../../Unit.t.sol";

contract CancelMultiple_Unit_Test is Unit_Test {
    function test_RevertWhen_NotDelegateCalled() external {
        IERC20[] memory assets;
        uint256[] memory streamIds;
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        target.cancelMultiple({ lockup: linear, assets: assets, streamIds: streamIds });
    }

    modifier whenDelegateCalled() {
        _;
    }

    function test_CancelMultiple_Dynamic() external whenDelegateCalled {
        uint256[] memory streamIds = batchCreateWithMilestones();
        test_CancelMultiple(dynamic, streamIds);
    }

    function test_CancelMultiple_Linear() external whenDelegateCalled {
        uint256[] memory streamIds = batchCreateWithRange();
        test_CancelMultiple(linear, streamIds);
    }

    function test_CancelMultiple(ISablierV2Lockup lockup, uint256[] memory streamIds) internal {
        // Simulate the passage of time.
        vm.warp(defaults.CLIFF_TIME());

        // Asset flow: Sablier → proxy → proxy owner
        expectMultipleCallsToTransfer({
            count: defaults.BATCH_SIZE(),
            to: address(proxy),
            amount: defaults.REFUND_AMOUNT()
        });
        expectCallToTransfer({ to: users.alice.addr, amount: defaults.REFUND_AMOUNT() * defaults.BATCH_SIZE() });

        // Cancel the streams.
        bytes memory data = abi.encodeCall(target.cancelMultiple, (lockup, defaults.assets(), streamIds));
        proxy.execute(address(target), data);

        // Assert that all streams have been canceled.
        Lockup.Status expectedStatus = Lockup.Status.CANCELED;
        for (uint256 i = 0; i < defaults.BATCH_SIZE(); ++i) {
            Lockup.Status actualStatus = lockup.getStatus(streamIds[i]);
            assertEq(actualStatus, expectedStatus, "stream status not canceled");
        }
    }
}
