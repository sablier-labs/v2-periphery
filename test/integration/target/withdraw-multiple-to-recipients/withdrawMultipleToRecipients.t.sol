// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ISablierV2Lockup } from "@sablier/v2-core/src/interfaces/ISablierV2Lockup.sol";

import { Errors } from "src/libraries/Errors.sol";

import { Target_Integration_Test } from "../Target.t.sol";

abstract contract WithdrawMultipleToRecipients_Integration_Test is Target_Integration_Test {
    function setUp() public virtual override { }

    function test_RevertWhen_NotDelegateCalled() external {
        uint256[] memory streamIds;
        uint128[] memory amounts;
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        target.withdrawMultipleToRecipients(lockupLinear, streamIds, amounts);
    }

    modifier whenDelegateCalled() {
        _;
    }

    function test_RevertWhen_ArrayCountsNotEqual() external whenDelegateCalled {
        uint256[] memory streamIds = new uint256[](2);
        uint128[] memory amounts = new uint128[](1);
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierV2ProxyTarget_WithdrawArrayCountsNotEqual.selector, streamIds.length, amounts.length
            )
        );
        bytes memory data = abi.encodeCall(target.withdrawMultipleToRecipients, (lockupLinear, streamIds, amounts));
        aliceProxy.execute(address(target), data);
    }

    modifier whenArrayCountsAreEqual() {
        _;
    }

    function test_WithdrawMultipleToRecipients_ArrayCountsZero() external whenDelegateCalled whenArrayCountsAreEqual {
        uint256[] memory streamIds = new uint256[](0);
        uint128[] memory amounts = new uint128[](0);
        bytes memory data = abi.encodeCall(target.withdrawMultipleToRecipients, (lockupLinear, streamIds, amounts));
        aliceProxy.execute(address(target), data);
    }

    modifier whenArrayCountsNotZero() {
        _;
    }

    function test_WithdrawMultipleToRecipients_LockupDynamic()
        external
        whenDelegateCalled
        whenArrayCountsAreEqual
        whenArrayCountsNotZero
    {
        uint256[] memory streamIds = batchCreateWithMilestones();
        test_WithdrawMultipleToRecipients(lockupDynamic, streamIds);
    }

    function test_WithdrawMultipleToRecipients_LockupLinear()
        external
        whenDelegateCalled
        whenArrayCountsAreEqual
        whenArrayCountsNotZero
    {
        uint256[] memory streamIds = batchCreateWithRange();
        test_WithdrawMultipleToRecipients(lockupLinear, streamIds);
    }

    function test_WithdrawMultipleToRecipients(ISablierV2Lockup lockup, uint256[] memory streamIds) internal {
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

        bytes memory data = abi.encodeCall(target.withdrawMultipleToRecipients, (lockup, streamIds, amounts));
        aliceProxy.execute(address(target), data);

        // Assert that the withdrawn amount has been updated for all streams.
        for (uint256 i = 0; i < batchSize; ++i) {
            assertEq(lockup.getWithdrawnAmount(streamIds[i]), withdrawAmount, "withdrawnAmount");
        }
    }
}
