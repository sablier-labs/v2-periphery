// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Base_Test } from "../../Base.t.sol";

contract OnStreamCanceled_Unit_Test is Base_Test {
    function test_OnStreamCanceled() external {
        uint256 streamId = createWithRange();

        // Warp into the future.
        vm.warp(defaults.WARP_26_PERCENT());

        // Make the `recipient` the caller.
        changePrank(users.recipient.addr);

        uint256 balanceBefore = dai.balanceOf(users.sender.addr);

        // Asset flow: Sablier contract → proxy → proxy owner
        // Expect transfers from the Sablier contract to the proxy, and then from the proxy to the proxy owner.
        expectCallToTransfer({ to: address(proxy), amount: defaults.REFUND_AMOUNT() });
        expectCallToTransfer({ to: users.sender.addr, amount: defaults.REFUND_AMOUNT() });

        // Cancel the stream.
        linear.cancel(streamId);

        uint256 actualBalance = dai.balanceOf(users.sender.addr);
        uint256 expectedBalance = balanceBefore + defaults.REFUND_AMOUNT();
        assertEq(actualBalance, expectedBalance, "balance does not match");
    }
}
