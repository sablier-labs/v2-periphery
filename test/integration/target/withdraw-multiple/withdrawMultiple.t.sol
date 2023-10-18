// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ISablierV2Lockup } from "@sablier/v2-core/src/interfaces/ISablierV2Lockup.sol";

import { Errors } from "src/libraries/Errors.sol";

import { Target_Integration_Test } from "../Target.t.sol";

abstract contract WithdrawMultiple_Integration_Test is Target_Integration_Test {
    function setUp() public virtual override { }

    function test_RevertWhen_NotDelegateCalled() external {
        uint256[] memory streamIds;
        uint128[] memory amounts;
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        target.withdrawMultiple(lockupLinear, streamIds, users.recipient0.addr, amounts);
    }

    modifier whenDelegateCalled() {
        _;
    }

    function test_WithdrawMultiple_LockupDynamic() external whenDelegateCalled {
        uint256[] memory streamIds = batchCreateWithMilestones();
        test_WithdrawMultiple(lockupDynamic, streamIds);
    }

    function test_WithdrawMultiple_LockupLinear() external whenDelegateCalled {
        uint256[] memory streamIds = batchCreateWithRange();
        test_WithdrawMultiple(lockupLinear, streamIds);
    }

    function test_WithdrawMultiple(ISablierV2Lockup lockup, uint256[] memory streamIds) internal {
        // Simulate the passage of time.
        vm.warp(defaults.CLIFF_TIME());

        uint40 batchSize = uint40(defaults.BATCH_SIZE());
        uint128 withdrawAmount = defaults.WITHDRAW_AMOUNT();

        // Asset flow: Sablier → recipient
        expectMultipleCallsToTransfer({ count: batchSize, to: users.recipient0.addr, amount: withdrawAmount });

        uint128[] memory amounts = new uint128[](batchSize);
        for (uint256 i = 0; i < batchSize; ++i) {
            amounts[i] = withdrawAmount;
        }

        bytes memory data = abi.encodeCall(target.withdrawMultiple, (lockup, streamIds, users.recipient0.addr, amounts));
        aliceProxy.execute(address(target), data);

        // Assert that the withdrawn amount has been updated for all streams.
        for (uint256 i = 0; i < batchSize; ++i) {
            assertEq(lockup.getWithdrawnAmount(streamIds[i]), withdrawAmount, "withdrawnAmount");
        }
    }
}
