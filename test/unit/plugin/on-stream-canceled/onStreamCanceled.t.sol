// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Errors } from "src/libraries/Errors.sol";
import { LockupLinear } from "src/types/DataTypes.sol";

import { Unit_Test } from "../../Unit.t.sol";

contract OnStreamCanceled_Unit_Test is Unit_Test {
    function setUp() public virtual override {
        Unit_Test.setUp();

        // Install the plugin on the proxy.
        installPlugin();
    }

    function test_RevertWhen_InvalidCall() external {
        // Create a standard stream.
        uint256 streamId = createWithRange();

        // Since the plugin is not meant to be called directly, the call below is invalid.
        vm.expectRevert(
            abi.encodeWithSelector(Errors.SablierV2ProxyPlugin_InvalidCall.selector, address(plugin), address(proxy))
        );

        // Call the plugin directly.
        uint128 senderAmount = 100e18;
        uint128 recipientAmount = 0;
        plugin.onStreamCanceled(linear, streamId, users.recipient.addr, senderAmount, recipientAmount);
    }

    modifier whenValidCall() {
        _;
    }

    function test_RevertWhen_PluginContractStreamSender() external whenValidCall {
        // Create a stream with the plugin contract as the sender.
        LockupLinear.CreateWithRange memory params = defaults.createWithRange();
        params.sender = address(plugin);
        uint256 streamId = createWithRange(params);

        // Retrieve the initial asset balance of the plugin contract.
        uint256 initialBalance = usdc.balanceOf(address(plugin));

        // Simulate the passage of time.
        vm.warp(defaults.CLIFF_TIME());

        // Make the recipient the caller so that Sablier calls the hook implemented by the plugin.
        changePrank({ msgSender: users.recipient.addr });

        // Asset flow: Sablier contract → plugin
        expectCallToTransfer({ to: address(plugin), amount: defaults.REFUND_AMOUNT() });

        // A call is attempted to transfer the assets from the plugin to the zero address, but it reverts
        // with error "ERC20: transfer to the zero address". Sablier does not bubble up the revert, so
        // the funds remain in the plugin contract.
        expectCallToTransfer({ to: address(0), amount: defaults.REFUND_AMOUNT() });

        // Cancel the stream and trigger the plugin.
        linear.cancel(streamId);

        // Assert that the balances match.
        uint256 actualBalance = usdc.balanceOf(address(plugin));
        uint256 expectedBalance = initialBalance + defaults.REFUND_AMOUNT();
        assertEq(actualBalance, expectedBalance, "balances do not match");
    }

    modifier whenPluginContractNotStreamSender() {
        _;
    }

    function test_OnStreamCanceled() external whenValidCall whenPluginContractNotStreamSender {
        // Create a standard stream.
        uint256 streamId = createWithRange();

        // Retrieve the initial asset balance of the proxy owner.
        uint256 initialBalance = usdc.balanceOf(users.sender.addr);

        // Simulate the passage of time.
        vm.warp(defaults.CLIFF_TIME());

        // Make the recipient the caller so that Sablier calls the hook implemented by the plugin.
        changePrank({ msgSender: users.recipient.addr });

        // Asset flow: Sablier contract → proxy → proxy owner
        // Expect transfers from the Sablier contract to the proxy, and then from the proxy to the proxy owner.
        expectCallToTransfer({ to: address(proxy), amount: defaults.REFUND_AMOUNT() });
        expectCallToTransfer({ to: users.sender.addr, amount: defaults.REFUND_AMOUNT() });

        // Cancel the stream and trigger the plugin.
        linear.cancel(streamId);

        // Assert that the balances match.
        uint256 actualBalance = usdc.balanceOf(users.sender.addr);
        uint256 expectedBalance = initialBalance + defaults.REFUND_AMOUNT();
        assertEq(actualBalance, expectedBalance, "balances do not match");
    }
}
