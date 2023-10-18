// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ISablierV2Lockup } from "@sablier/v2-core/src/interfaces/ISablierV2Lockup.sol";

import { Errors } from "src/libraries/Errors.sol";

import { Target_Integration_Test } from "../Target.t.sol";

abstract contract WithdrawMax_Integration_Test is Target_Integration_Test {
    function setUp() public virtual override { }

    function test_RevertWhen_NotDelegateCalled() external {
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        target.withdrawMax({ lockup: lockupLinear, streamId: 0, to: users.recipient0.addr });
    }

    modifier whenDelegateCalled() {
        _;
    }

    function test_WithdrawMax_LockupDynamic() external whenDelegateCalled {
        uint256 streamId = createWithMilestones();
        test_WithdrawMax(lockupDynamic, streamId);
    }

    function test_WithdrawMax_Linear() external whenDelegateCalled {
        uint256 streamId = createWithRange();
        test_WithdrawMax(lockupLinear, streamId);
    }

    function test_WithdrawMax(ISablierV2Lockup lockup, uint256 streamId) internal {
        // Simulate the passage of time.
        vm.warp(defaults.END_TIME());

        // Asset flow: Sablier → recipient
        expectCallToTransfer({ to: users.recipient0.addr, amount: defaults.PER_STREAM_AMOUNT() });

        // Withdraw all assets from the stream.
        bytes memory data = abi.encodeCall(target.withdrawMax, (lockup, streamId, users.recipient0.addr));
        aliceProxy.execute(address(target), data);

        // Assert that the withdrawn amount has been updated.
        uint128 actualWithdrawnAmount = lockup.getWithdrawnAmount(streamId);
        uint128 expectedWithdrawnAmount = defaults.PER_STREAM_AMOUNT();
        assertEq(actualWithdrawnAmount, expectedWithdrawnAmount, "withdrawnAmount");
    }
}
