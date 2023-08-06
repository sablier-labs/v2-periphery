// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ISablierV2Lockup } from "@sablier/v2-core/interfaces/ISablierV2Lockup.sol";
import { Lockup } from "@sablier/v2-core/types/DataTypes.sol";

import { Errors } from "src/libraries/Errors.sol";

import { Integration_Test } from "../../../Integration.t.sol";

abstract contract Cancel_Integration_Test is Integration_Test {
    function setUp() public virtual override {
        Integration_Test.setUp();
    }

    function test_RevertWhen_NotDelegateCalled() external {
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        target.cancel({ lockup: lockupLinear, streamId: 0 });
    }

    modifier whenDelegateCalled() {
        _;
    }

    function test_Cancel_LockupDynamic() external whenDelegateCalled {
        uint256 streamId = createWithMilestones();
        test_Cancel(lockupDynamic, streamId);
    }

    function test_Cancel_LockupLinear() external whenDelegateCalled {
        uint256 streamId = createWithRange();
        test_Cancel(lockupLinear, streamId);
    }

    function test_Cancel(ISablierV2Lockup lockup, uint256 streamId) internal {
        // Simulate the passage of time.
        vm.warp(defaults.CLIFF_TIME());

        // Asset flow: Sablier → proxy → proxy owner
        expectCallToTransfer({ to: address(aliceProxy), amount: defaults.REFUND_AMOUNT() });
        expectCallToTransfer({ to: users.alice.addr, amount: defaults.REFUND_AMOUNT() });

        // Cancel the stream.
        bytes memory data = abi.encodeCall(target.cancel, (lockup, streamId));
        aliceProxy.execute(address(target), data);

        // Assert that the stream has been canceled.
        Lockup.Status expectedStatus = Lockup.Status.CANCELED;
        Lockup.Status actualStatus = lockup.statusOf(streamId);
        assertEq(actualStatus, expectedStatus, "stream not canceled");
    }
}
