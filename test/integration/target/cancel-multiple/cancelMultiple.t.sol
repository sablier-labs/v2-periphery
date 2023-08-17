// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ISablierV2Lockup } from "@sablier/v2-core/src/interfaces/ISablierV2Lockup.sol";
import { Lockup } from "@sablier/v2-core/src/types/DataTypes.sol";

import { Errors } from "src/libraries/Errors.sol";

import { Integration_Test } from "../../Integration.t.sol";

abstract contract CancelMultiple_Integration_Test is Integration_Test {
    function setUp() public virtual override { }

    function test_RevertWhen_NotDelegateCalled() external {
        IERC20[] memory assets;
        uint256[] memory streamIds;
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        target.cancelMultiple(lockupLinear, assets, streamIds);
    }

    modifier whenDelegateCalled() {
        _;
    }

    function test_CancelMultiple_LockupDynamic() external whenDelegateCalled {
        uint256[] memory streamIds = batchCreateWithMilestones();
        test_CancelMultiple(lockupDynamic, streamIds);
    }

    function test_CancelMultiple_LockupLinear() external whenDelegateCalled {
        uint256[] memory streamIds = batchCreateWithRange();
        test_CancelMultiple(lockupLinear, streamIds);
    }

    function test_CancelMultiple(ISablierV2Lockup lockup, uint256[] memory streamIds) internal {
        // Simulate the passage of time.
        vm.warp(defaults.CLIFF_TIME());

        // Asset flow: Sablier → proxy → proxy owner
        expectMultipleCallsToTransfer({
            count: defaults.BATCH_SIZE(),
            to: address(aliceProxy),
            amount: defaults.REFUND_AMOUNT()
        });
        expectCallToTransfer({ to: users.alice.addr, amount: defaults.REFUND_AMOUNT() * defaults.BATCH_SIZE() });

        bytes memory data = abi.encodeCall(target.cancelMultiple, (lockup, defaults.assets(), streamIds));
        aliceProxy.execute(address(target), data);

        // Assert that all streams have been canceled.
        Lockup.Status expectedStatus = Lockup.Status.CANCELED;
        for (uint256 i = 0; i < defaults.BATCH_SIZE(); ++i) {
            Lockup.Status actualStatus = lockup.statusOf(streamIds[i]);
            assertEq(actualStatus, expectedStatus, "stream status not canceled");
        }
    }
}
