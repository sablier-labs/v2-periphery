// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { Fuzzers } from "@sablier/v2-core-test/utils/Fuzzers.sol";
import { IAllowanceTransfer } from "permit2/interfaces/IAllowanceTransfer.sol";
import { PermitSignature } from "permit2-test/utils/PermitSignature.sol";

import { Fork_Test } from "../../Fork.t.sol";

import { LockupLinear, Permit2Params } from "src/types/DataTypes.sol";

abstract contract OnStreamCanceled_Fork_Test is Fork_Test, Fuzzers, PermitSignature {
    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Runs against multiple assets.
    constructor(IERC20 asset_) Fork_Test(asset_) { }

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        Fork_Test.setUp();
        installPlugin();

        changePrank({ msgSender: users.admin.addr });
        archive.list(address(linear));
        changePrank({ msgSender: users.alice.addr });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function test_ForkFuzz_OnStreamCanceled(uint256 balanceAmount) external {
        balanceAmount = _bound(balanceAmount, defaults.PER_STREAM_AMOUNT(), MAX_UINT128 - 1);

        deal({ token: address(asset), to: users.alice.addr, give: balanceAmount });

        // Approve {Permit2} to transfer the Alice's assets.
        // We use a low-level call to ignore reverts because the asset can have the missing return value bug.
        (bool success,) = address(asset).call(abi.encodeCall(IERC20.approve, (address(permit2), MAX_UINT256)));
        success;

        LockupLinear.CreateWithRange memory createParams = defaults.createWithRange();
        createParams.asset = asset;

        Permit2Params memory permit2Params = defaults.permit2Params(defaults.PER_STREAM_AMOUNT());
        permit2Params.permitSingle.details.token = address(asset);
        permit2Params.signature =
            getPermitSignature(permit2Params.permitSingle, users.alice.key, permit2.DOMAIN_SEPARATOR());

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data = abi.encodeCall(target.createWithRange, (linear, createParams, permit2Params));
        bytes memory response = proxy.execute(address(target), data);
        uint256 streamId = abi.decode(response, (uint256));

        // Retrieve the initial asset balance of the proxy owner.
        uint256 initialBalance = asset.balanceOf(users.alice.addr);

        // Simulate the passage of time.
        vm.warp(defaults.CLIFF_TIME());

        // Make the recipient the caller so that Sablier calls the hook implemented by the plugin.
        changePrank({ msgSender: users.recipient.addr });

        // Asset flow: Sablier contract → proxy → proxy owner
        // Expect transfers from the Sablier contract to the proxy, and then from the proxy to the proxy owner.
        expectCallToTransfer({ asset: address(asset), to: address(proxy), amount: defaults.REFUND_AMOUNT() });
        expectCallToTransfer({ asset: address(asset), to: users.alice.addr, amount: defaults.REFUND_AMOUNT() });

        // Cancel the stream and trigger the plugin.
        linear.cancel(streamId);

        // Assert that the balances match.
        uint256 actualBalance = asset.balanceOf(users.alice.addr);
        uint256 expectedBalance = initialBalance + defaults.REFUND_AMOUNT();
        assertEq(actualBalance, expectedBalance, "balances do not match");
    }
}
