// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ISablierV2Lockup } from "@sablier/v2-core/interfaces/ISablierV2Lockup.sol";

import { Errors } from "src/libraries/Errors.sol";

import { Unit_Test } from "../../Unit.t.sol";

contract WithdrawMax_Unit_Test is Unit_Test {
    function test_RevertWhen_NotDelegateCalled() external {
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        target.withdrawMax({ lockup: linear, streamId: 0, to: users.recipient.addr });
    }

    modifier whenDelegateCalled() {
        _;
    }

    function test_WithdrawMax_Dynamic() external whenDelegateCalled {
        uint256 streamId = createWithMilestones();
        test_WithdrawMax(dynamic, streamId);
    }

    function test_WithdrawMax_Linear() external whenDelegateCalled {
        uint256 streamId = createWithRange();
        test_WithdrawMax(linear, streamId);
    }

    function test_WithdrawMax(ISablierV2Lockup lockup, uint256 streamId) internal {
        // Simulate the passage of time.
        vm.warp(defaults.END_TIME());

        // Asset flow: Sablier → recipient
        expectCallToTransfer({ to: users.recipient.addr, amount: defaults.PER_STREAM_AMOUNT() });

        // Withdraw all assets from the stream.
        bytes memory data = abi.encodeCall(target.withdrawMax, (lockup, streamId, users.recipient.addr));
        proxy.execute(address(target), data);

        // Assert that the withdrawn amount has been updated.
        uint128 actualWithdrawnAmount = lockup.getWithdrawnAmount(streamId);
        uint128 expectedWithdrawnAmount = defaults.PER_STREAM_AMOUNT();
        assertEq(actualWithdrawnAmount, expectedWithdrawnAmount, "withdrawnAmount");
    }
}
