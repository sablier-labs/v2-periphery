// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ISablierV2Lockup } from "@sablier/v2-core/interfaces/ISablierV2Lockup.sol";

import { Errors } from "src/libraries/Errors.sol";

import { Integration_Test } from "../../Integration.t.sol";

contract Withdraw_Integration_Test is Integration_Test {
    function test_RevertWhen_NotDelegateCalled() external {
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        target.withdraw({ lockup: lockupLinear, streamId: 0, to: users.recipient.addr, amount: 0 });
    }

    modifier whenDelegateCalled() {
        _;
    }

    function test_Withdraw_LockupDynamic() external whenDelegateCalled {
        uint256 streamId = createWithMilestones();
        test_Withdraw(lockupDynamic, streamId);
    }

    function test_Withdraw_LockupLinear() external whenDelegateCalled {
        uint256 streamId = createWithRange();
        test_Withdraw(lockupLinear, streamId);
    }

    function test_Withdraw(ISablierV2Lockup lockup, uint256 streamId) internal {
        // Simulate the passage of time.
        vm.warp(defaults.CLIFF_TIME());

        // Asset flow: Sablier → recipient
        expectCallToTransfer({ to: users.recipient.addr, amount: defaults.WITHDRAW_AMOUNT() });

        // Withdraw from the stream.
        bytes memory data =
            abi.encodeCall(target.withdraw, (lockup, streamId, users.recipient.addr, defaults.WITHDRAW_AMOUNT()));
        aliceProxy.execute(address(target), data);

        // Assert that the withdrawn amount has been updated.
        uint128 actualWithdrawnAmount = lockup.getWithdrawnAmount(streamId);
        uint128 expectedWithdrawnAmount = defaults.WITHDRAW_AMOUNT();
        assertEq(actualWithdrawnAmount, expectedWithdrawnAmount, "withdrawnAmount");
    }
}
