// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ISablierV2LockupSender } from "@sablier/v2-core/src/interfaces/hooks/ISablierV2LockupSender.sol";

import { ISablierV2ProxyPlugin } from "src/interfaces/ISablierV2ProxyPlugin.sol";
import { Errors } from "src/libraries/Errors.sol";

import { Integration_Test } from "../../Integration.t.sol";

contract OnStreamCanceled_Integration_Test is Integration_Test {
    uint256 internal streamId;

    function setUp() public virtual override {
        Integration_Test.setUp();
        proxyRegistry.installPlugin(plugin);
        streamId = createWithRange();

        // List the {LockupLinear} contract in the archive.
        changePrank({ msgSender: users.admin.addr });
        archive.list(address(lockupLinear));
        changePrank({ msgSender: users.alice.addr });
    }

    function test_RevertWhen_NotDelegateCalled() external {
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        plugin.onStreamCanceled({
            streamId: streamId,
            recipient: users.recipient.addr,
            senderAmount: 100e18,
            recipientAmount: 0
        });
    }

    modifier whenDelegateCalled() {
        _;
    }

    function test_RevertWhen_CallerNotListed() external whenDelegateCalled {
        changePrank({ msgSender: users.eve.addr });
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2ProxyPlugin_UnknownCaller.selector, users.eve.addr));
        ISablierV2ProxyPlugin(address(aliceProxy)).onStreamCanceled({
            streamId: streamId,
            recipient: users.recipient.addr,
            senderAmount: 100e18,
            recipientAmount: 0
        });
    }

    modifier whenCallerListed() {
        _;
    }

    function test_OnStreamCanceled() external whenDelegateCalled whenCallerListed {
        // Retrieve the initial asset balance of the proxy owner.
        uint256 initialBalance = asset.balanceOf(users.alice.addr);

        // Simulate the passage of time.
        vm.warp(defaults.CLIFF_TIME());

        // Make the recipient the caller so that Sablier calls the hook implemented by the plugin.
        changePrank({ msgSender: users.recipient.addr });

        // Expect a call to the hook.
        uint128 senderAmount = defaults.REFUND_AMOUNT();
        uint128 recipientAmount = defaults.WITHDRAW_AMOUNT();
        vm.expectCall(
            address(aliceProxy),
            abi.encodeCall(
                ISablierV2LockupSender.onStreamCanceled, (streamId, users.recipient.addr, senderAmount, recipientAmount)
            )
        );

        // Asset flow: Sablier contract → proxy → proxy owner
        // Expect transfers from the Sablier contract to the proxy, and then from the proxy to the proxy owner.
        expectCallToTransfer({ to: address(aliceProxy), amount: senderAmount });
        expectCallToTransfer({ to: users.alice.addr, amount: senderAmount });

        // Cancel the stream and trigger the plugin.
        lockupLinear.cancel(streamId);

        // Assert that the balances match.
        uint256 actualBalance = asset.balanceOf(users.alice.addr);
        uint256 expectedBalance = initialBalance + senderAmount;
        assertEq(actualBalance, expectedBalance, "balances mismatch");
    }
}
