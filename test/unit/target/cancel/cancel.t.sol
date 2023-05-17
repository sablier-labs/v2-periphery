// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ISablierV2Lockup } from "@sablier/v2-core/interfaces/ISablierV2Lockup.sol";
import { Lockup } from "@sablier/v2-core/types/DataTypes.sol";

import { Errors } from "src/libraries/Errors.sol";

import { Unit_Test } from "../../Unit.t.sol";

contract Cancel_Unit_Test is Unit_Test {
    function test_RevertWhen_NotDelegateCalled() external {
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        target.cancel({ lockup: linear, streamId: 0 });
    }

    modifier whenDelegateCalled() {
        _;
    }

    function test_Cancel_Linear() external whenDelegateCalled {
        uint256 streamId = createWithRange();
        test_Cancel(linear, streamId);
    }

    function test_Cancel_Dynamic() external whenDelegateCalled {
        uint256 streamId = createWithMilestones();
        test_Cancel(dynamic, streamId);
    }

    function test_Cancel(ISablierV2Lockup lockup, uint256 streamId) internal {
        // Simulate the passage of time.
        vm.warp(defaults.CLIFF_TIME());

        // Asset flow: proxy owner → proxy → proxy owner
        expectCallToTransfer({ to: address(proxy), amount: defaults.REFUND_AMOUNT() });
        expectCallToTransfer({ to: users.alice.addr, amount: defaults.REFUND_AMOUNT() });

        // Cancel the stream.
        bytes memory data = abi.encodeCall(target.cancel, (lockup, streamId));
        proxy.execute(address(target), data);

        // Assert that the stream has been canceled.
        Lockup.Status expectedStatus = Lockup.Status.CANCELED;
        Lockup.Status actualStatus = lockup.getStatus(streamId);
        assertEq(actualStatus, expectedStatus, "stream not canceled");
    }
}
