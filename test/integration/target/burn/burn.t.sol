// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ISablierV2Lockup } from "@sablier/v2-core/src/interfaces/ISablierV2Lockup.sol";
import { LockupDynamic, LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { Errors } from "src/libraries/Errors.sol";

import { Integration_Test } from "../../Integration.t.sol";

abstract contract Burn_Integration_Test is Integration_Test {
    function setUp() public virtual override { }

    function test_RevertWhen_NotDelegateCalled() external {
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        target.burn({ lockup: lockupLinear, streamId: 0 });
    }

    modifier whenDelegateCalled() {
        _;
    }

    function test_Burn_LockupDynamic() external whenDelegateCalled {
        LockupDynamic.CreateWithMilestones memory params = defaults.createWithMilestones();
        params.recipient = address(aliceProxy);
        uint256 streamId = createWithMilestones(params);
        test_Burn(lockupDynamic, streamId);
    }

    function test_Burn_LockupLinear() external whenDelegateCalled {
        LockupLinear.CreateWithRange memory params = defaults.createWithRange();
        params.recipient = address(aliceProxy);
        uint256 streamId = createWithRange(params);
        test_Burn(lockupLinear, streamId);
    }

    function test_Burn(ISablierV2Lockup lockup, uint256 streamId) internal {
        // Simulate the passage of time.
        vm.warp(defaults.END_TIME());

        // Make the withdrawal.
        bytes memory data = abi.encodeCall(target.withdrawMax, (lockup, streamId, address(aliceProxy)));
        aliceProxy.execute(address(target), data);

        // Burn the stream.
        data = abi.encodeCall(target.burn, (lockup, streamId));
        aliceProxy.execute(address(target), data);

        // Expect the NFT owner to not exist anymore.
        vm.expectRevert("ERC721: invalid token ID");
        lockup.getRecipient(streamId);
    }
}
