// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IPRBProxy } from "@prb/proxy/interfaces/IPRBProxy.sol";
import { IPRBProxyAnnex } from "@prb/proxy/interfaces/IPRBProxyAnnex.sol";
import { IPRBProxyRegistry } from "@prb/proxy/interfaces/IPRBProxyRegistry.sol";
import { ISablierV2LockupDynamic } from "@sablier/v2-core/interfaces/ISablierV2LockupDynamic.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";
import { IAllowanceTransfer } from "permit2/interfaces/IAllowanceTransfer.sol";

import { Fuzzers as V2CoreFuzzers } from "@sablier/v2-core-test/utils/Fuzzers.sol";
import { IWrappedNativeAsset } from "src/interfaces/IWrappedNativeAsset.sol";

import { Defaults } from "../utils/Defaults.sol";
import { Base_Test } from "../Base.t.sol";

/// @notice Common logic needed by all fork tests.
abstract contract Fork_Test is Base_Test, V2CoreFuzzers {
    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Goerli address of WETH.
    address internal constant WETH_ADDRESS = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor(IERC20 asset_) {
        asset = asset_;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        // Fork the Goerli testnet.
        vm.createSelectFork({ blockNumber: 9_093_100, urlOrAlias: "goerli" });

        // Set up the base test contract.
        Base_Test.setUp();

        // Load the external dependencies.
        loadDependencies();

        // Deploy the defaults contract.
        defaults = new Defaults(users, asset, permit2, proxy);

        // Deploy V2 Periphery.
        deployPeripheryConditionally();

        // Label the contracts.
        labelContracts();

        // Make Alice the default caller.
        vm.startPrank({ msgSender: users.alice.addr });

        // Approve {Permit2} to transfer Alice's assets.
        // We use a low-level call to ignore reverts because the asset can have the missing return value bug.
        (bool success,) = address(asset).call(abi.encodeCall(IERC20.approve, (address(permit2), MAX_UINT256)));
        success;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Checks the user assumptions.
    function checkUsers(address user, address recipient, address proxy_) internal virtual {
        // The protocol does not allow the zero address to interact with it.
        vm.assume(user != address(0) && recipient != address(0));

        // The goal is to not have overlapping users because the asset balance tests would fail otherwise.
        vm.assume(user != recipient && user != address(proxy_) && recipient != address(proxy_));
        vm.assume(user != address(lockupDynamic) && recipient != address(lockupDynamic));
        vm.assume(user != address(lockupLinear) && recipient != address(lockupLinear));

        // Avoid users blacklisted by USDC or USDT.
        assumeNoBlacklisted(address(asset), user);
        assumeNoBlacklisted(address(asset), recipient);
        assumeNoBlacklisted(address(asset), proxy_);
    }

    /// @dev Loads all dependencies pre-deployed on Goerli.
    function loadDependencies() private {
        // Load WETH.
        weth = IWrappedNativeAsset(WETH_ADDRESS);

        // Load the proxy annex.
        proxyAnnex = IPRBProxyAnnex(0x0254C4467cBbdbe8d5E01e68de0DF7b20dD2A167);

        // Load the proxy registry.
        proxyRegistry = IPRBProxyRegistry(0xa87bc4C1Bc54E1C1B28d2dD942A094A6B665B8C9);

        // Deploy a proxy for Alice if needed.
        proxy = proxyRegistry.proxies(users.alice.addr);
        if (address(proxy) == address(0)) {
            proxy = proxyRegistry.deployFor(users.alice.addr);
        }

        // Load Permit2.
        permit2 = IAllowanceTransfer(0x000000000022D473030F116dDEE9F6B43aC78BA3);

        // Load V2 Core.
        lockupDynamic = ISablierV2LockupDynamic(0xB2CF57EdDEf081b97A4F2a02f5f6DF1271d0071E);
        lockupLinear = ISablierV2LockupLinear(0x1366C6257033e23c6736722dC2E826AfF0b13EdB);
    }
}
