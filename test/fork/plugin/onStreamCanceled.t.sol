// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { LockupLinear } from "@sablier/v2-core/types/DataTypes.sol";
import { PermitSignature } from "permit2-test/utils/PermitSignature.sol";

import { Fork_Test } from "../Fork.t.sol";

import { Permit2Params } from "src/types/Permit2.sol";

/// @dev Runs against multiple fork assets.
abstract contract OnStreamCanceled_Fork_Test is Fork_Test, PermitSignature {
    constructor(IERC20 asset_) Fork_Test(asset_) { }

    function setUp() public virtual override {
        Fork_Test.setUp();
        proxyRegistry.installPlugin(plugin);

        if (!archive.isListed(address(lockupLinear))) {
            address archiveAdmin = archive.admin();
            changePrank({ msgSender: archiveAdmin });
            archive.list(address(lockupLinear));
            changePrank({ msgSender: users.alice.addr });
        }
    }

    function testForkFuzz_OnStreamCanceled(uint128 amount, uint256 timeJump) external {
        amount = boundUint128(amount, defaults.PER_STREAM_AMOUNT(), MAX_UINT128);
        timeJump = _bound(timeJump, 100 seconds, defaults.TOTAL_DURATION() - 1 seconds);

        // Mint the fuzzed amount to the proxy owner.
        deal({ token: address(asset), to: users.alice.addr, give: amount });

        // ABI encode the parameters and call the function via the proxy.
        LockupLinear.CreateWithRange memory createParams = defaults.createWithRange(asset);
        createParams.totalAmount = amount;
        Permit2Params memory permit2Params = defaults.permit2Params(amount);
        bytes memory data = abi.encodeCall(target.createWithRange, (lockupLinear, createParams, permit2Params));
        bytes memory response = aliceProxy.execute(address(target), data);
        uint256 streamId = abi.decode(response, (uint256));

        // Retrieve the initial asset balance of the proxy owner.
        uint256 initialBalance = asset.balanceOf(users.alice.addr);

        // Simulate the passage of time.
        vm.warp({ timestamp: defaults.START_TIME() + timeJump });

        // Make the recipient the caller so that Sablier calls the hook implemented by the plugin.
        changePrank({ msgSender: users.recipient.addr });

        // Retrieve the refund amount
        uint128 refundAmount = lockupLinear.refundableAmountOf(streamId);

        // Asset flow: Sablier contract → proxy → proxy owner
        // Expect transfers from the Sablier contract to the proxy, and then from the proxy to the proxy owner.
        expectCallToTransfer({ asset_: address(asset), to: address(aliceProxy), amount: refundAmount });
        expectCallToTransfer({ asset_: address(asset), to: users.alice.addr, amount: refundAmount });

        // Cancel the stream and trigger the plugin.
        lockupLinear.cancel(streamId);

        // Assert that the balances match.
        uint256 actualBalance = asset.balanceOf(users.alice.addr);
        uint256 expectedBalance = initialBalance + refundAmount;
        assertEq(actualBalance, expectedBalance, "balances mismatch");
    }
}
