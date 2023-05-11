// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ISablierV2ProxyPlugin } from "src/interfaces/ISablierV2ProxyPlugin.sol";
import { Errors } from "src/libraries/Errors.sol";
import { LockupLinear } from "src/types/DataTypes.sol";

import { Unit_Test } from "../../Unit.t.sol";

contract OnStreamCanceled_Unit_Test is Unit_Test {
    uint256 internal streamId;

    function setUp() public virtual override {
        Unit_Test.setUp();
        installPlugin();
        streamId = createWithRange();

        // Lists the linear contract in the chain log.
        changePrank({ msgSender: users.admin.addr });
        chainLog.list(address(linear));
        changePrank({ msgSender: users.alice.addr });
    }

    function test_RevertWhen_CallNotDelegateCall() external {
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        plugin.onStreamCanceled({
            lockup: linear,
            streamId: streamId,
            recipient: users.recipient.addr,
            senderAmount: 100e18,
            recipientAmount: 0
        });
    }

    modifier whenDelegateCall() {
        _;
    }

    function test_RevertWhen_CallerNotSablier() external whenDelegateCall {
        changePrank({ msgSender: users.eve.addr });
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2ProxyPlugin_CallerUnlisted.selector, users.eve.addr));
        ISablierV2ProxyPlugin(address(proxy)).onStreamCanceled({
            lockup: linear,
            streamId: streamId,
            recipient: users.recipient.addr,
            senderAmount: 100e18,
            recipientAmount: 0
        });
    }

    modifier whenCallerSablier() {
        _;
    }

    function test_OnStreamCanceled() external whenDelegateCall whenCallerSablier {
        // Retrieve the initial asset balance of the proxy owner.
        uint256 initialBalance = dai.balanceOf(users.alice.addr);

        // Simulate the passage of time.
        vm.warp(defaults.CLIFF_TIME());

        // Make the recipient the caller so that Sablier calls the hook implemented by the plugin.
        changePrank({ msgSender: users.recipient.addr });

        // Asset flow: Sablier contract → proxy → proxy owner
        // Expect transfers from the Sablier contract to the proxy, and then from the proxy to the proxy owner.
        expectCallToTransfer({ to: address(proxy), amount: defaults.REFUND_AMOUNT() });
        expectCallToTransfer({ to: users.alice.addr, amount: defaults.REFUND_AMOUNT() });

        // Cancel the stream and trigger the plugin.
        linear.cancel(streamId);

        // Assert that the balances match.
        uint256 actualBalance = dai.balanceOf(users.alice.addr);
        uint256 expectedBalance = initialBalance + defaults.REFUND_AMOUNT();
        assertEq(actualBalance, expectedBalance, "balances do not match");
    }
}
