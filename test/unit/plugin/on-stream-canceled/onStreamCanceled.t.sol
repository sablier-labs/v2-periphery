// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Unit_Test } from "../../Unit.t.sol";

contract OnStreamCanceled_Unit_Test is Unit_Test {
    function setUp() public override {
        Unit_Test.setUp();
        installPlugin();
    }

    function test_OnStreamCanceled() external {
        uint256 streamId = createWithRange();

        // Simulate the passage of time.
        vm.warp(defaults.CLIFF_TIME());

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
