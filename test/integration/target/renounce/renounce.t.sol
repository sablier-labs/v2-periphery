// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ISablierV2Lockup } from "@sablier/v2-core/src/interfaces/ISablierV2Lockup.sol";

import { Errors } from "src/libraries/Errors.sol";

import { Target_Integration_Test } from "../Target.t.sol";

abstract contract Renounce_Integration_Test is Target_Integration_Test {
    function setUp() public virtual override { }

    function test_RevertWhen_NotDelegateCalled() external {
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        target.renounce({ lockup: lockupLinear, streamId: 0 });
    }

    modifier whenDelegateCalled() {
        _;
    }

    function test_Renounce_LockupDynamic() external whenDelegateCalled {
        uint256 streamId = createWithMilestones();
        test_Renounce(lockupDynamic, streamId);
    }

    function test_Renounce_LockupLinear() external whenDelegateCalled {
        uint256 streamId = createWithRange();
        test_Renounce(lockupLinear, streamId);
    }

    function test_Renounce(ISablierV2Lockup lockup, uint256 streamId) internal {
        // Simulate the passage of time.
        vm.warp(defaults.CLIFF_TIME());

        // Load the initial state.
        bool initialIsCancelable = lockup.isCancelable(streamId);
        assertTrue(initialIsCancelable, "stream renounced already");

        // Renounce the stream.
        bytes memory data = abi.encodeCall(target.renounce, (lockup, streamId));
        aliceProxy.execute(address(target), data);

        // Assert that the stream has been renounced.
        bool finalIsCancelable = lockup.isCancelable(streamId);
        assertFalse(finalIsCancelable, "stream not renounced");
    }
}
