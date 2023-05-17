// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ISablierV2Lockup } from "@sablier/v2-core/interfaces/ISablierV2Lockup.sol";

import { Errors } from "src/libraries/Errors.sol";

import { Unit_Test } from "../../Unit.t.sol";

contract Renounce_Unit_Test is Unit_Test {
    function test_RevertWhen_NotDelegateCalled() external {
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        target.renounce({ lockup: linear, streamId: 0 });
    }

    modifier whenDelegateCalled() {
        _;
    }

    function test_Renounce_Dynamic() external whenDelegateCalled {
        uint256 streamId = createWithMilestones();
        test_Renounce(dynamic, streamId);
    }

    function test_Renounce_Linear() external whenDelegateCalled {
        uint256 streamId = createWithRange();
        test_Renounce(linear, streamId);
    }

    function test_Renounce(ISablierV2Lockup lockup, uint256 streamId) internal {
        // Simulate the passage of time.
        vm.warp(defaults.CLIFF_TIME());

        // Load the initial state.
        bool initialIsCancelable = lockup.isCancelable(streamId);
        assertTrue(initialIsCancelable, "stream renounced already");

        // Renounce the stream.
        bytes memory data = abi.encodeCall(target.renounce, (lockup, streamId));
        proxy.execute(address(target), data);

        // Assert that the stream has been renounced.
        bool finalIsCancelable = lockup.isCancelable(streamId);
        assertFalse(finalIsCancelable, "stream not renounced");
    }
}
