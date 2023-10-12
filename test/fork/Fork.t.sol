// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IPRBProxy } from "@prb/proxy/src/interfaces/IPRBProxy.sol";
import { IPRBProxyRegistry } from "@prb/proxy/src/interfaces/IPRBProxyRegistry.sol";
// import { ISablierV2LockupDynamic } from "@sablier/v2-core/src/interfaces/ISablierV2LockupDynamic.sol";
// import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { Precompiles as V2CorePrecompiles } from "@sablier/v2-core-test/utils/Precompiles.sol";
import { IAllowanceTransfer } from "@uniswap/permit2/interfaces/IAllowanceTransfer.sol";

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
    address internal constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

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
        // Fork Ethereum Mainnet at a specific block number.
        vm.createSelectFork({ blockNumber: 17_665_000, urlOrAlias: "mainnet" });

        // Set up the base test contract.
        Base_Test.setUp();

        // Load the external dependencies.
        loadDependencies();

        // Deploy the defaults contract and allow it to access cheatcodes.
        defaults = new Defaults(users, asset, permit2, aliceProxy);
        vm.allowCheatcodes(address(defaults));

        // Deploy V2 Periphery.
        deployPeripheryConditionally();

        // Label the contracts.
        labelContracts();

        // Approve the relevant contracts.
        approveContracts();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Approves the proxy or uses Permit2 to spend assets from the current pranked user.
    function approveProxyOrPermit2(address proxy) internal {
        if (target == targetApprove) {
            asset.approve({ spender: proxy, amount: MAX_UINT256 });
        } else if (target == targetPermit2) {
            maxApprovePermit2();
        }
    }

    /// @dev Checks the user assumptions.
    function checkUsers(address user, address recipient, address proxy_) internal virtual {
        checkUsers(user, recipient);

        vm.assume(user != address(proxy_) && recipient != address(proxy_));
        assumeNoBlacklisted(address(asset), proxy_);
    }

    /// @dev Checks the user assumptions.
    function checkUsers(address user, address recipient) internal virtual {
        // The protocol does not allow the zero address to interact with it.
        vm.assume(user != address(0) && recipient != address(0));

        // The goal is to not have overlapping users because the asset balance tests would fail otherwise.
        vm.assume(user != recipient);
        vm.assume(user != address(lockupDynamic) && recipient != address(lockupDynamic));
        vm.assume(user != address(lockupLinear) && recipient != address(lockupLinear));

        // Avoid users blacklisted by USDC or USDT.
        assumeNoBlacklisted(address(asset), user);
        assumeNoBlacklisted(address(asset), recipient);
    }

    /// @dev Loads all dependencies pre-deployed on Mainnet.
    function loadDependencies() private {
        weth = IWrappedNativeAsset(WETH_ADDRESS);
        proxyRegistry = IPRBProxyRegistry(0x584009E9eDe26e212182c9745F5c000191296a78);
        aliceProxy = loadOrDeployProxy(users.alice.addr);
        permit2 = IAllowanceTransfer(0x000000000022D473030F116dDEE9F6B43aC78BA3);
        // TODO: update the contract addresses once they are deployed.
        (, lockupDynamic, lockupLinear,) = new V2CorePrecompiles().deployCore(users.admin.addr);
    }

    /// @dev Retrieves the proxy and deploys one if none is found.
    function loadOrDeployProxy(address user) internal returns (IPRBProxy proxy) {
        proxy = proxyRegistry.getProxy(user);
        if (address(proxy) == address(0)) {
            proxy = proxyRegistry.deployFor(user);
        }
    }

    /// @dev Approve Permit2 to spend assets from the current pranked user. We use a low-level call to ignore reverts
    /// because the asset contract may have the missing return value bug.
    function maxApprovePermit2() internal {
        (bool success,) = address(asset).call(abi.encodeCall(IERC20.approve, (address(permit2), MAX_UINT256)));
        success;
    }
}
