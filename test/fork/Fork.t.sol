// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IPRBProxyHelpers } from "@prb/proxy/interfaces/IPRBProxyHelpers.sol";
import { IPRBProxyRegistry } from "@prb/proxy/interfaces/IPRBProxyRegistry.sol";
import { ISablierV2LockupDynamic } from "@sablier/v2-core/interfaces/ISablierV2LockupDynamic.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";
import { IAllowanceTransfer } from "permit2/interfaces/IAllowanceTransfer.sol";

import { IWrappedNativeAsset } from "src/interfaces/IWrappedNativeAsset.sol";

import { Defaults } from "../utils/Defaults.sol";
import { Base_Test } from "../Base.t.sol";

/// @title Fork_Test
/// @notice Common logic needed by all fork tests.
abstract contract Fork_Test is Base_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        // Fork the Goerli testnet.
        vm.createSelectFork({ blockNumber: 8_856_000, urlOrAlias: "goerli" });

        // The base is set up after the fork is selected so that the base test contracts are deployed on the fork.
        Base_Test.setUp();

        // Load the dependencies.
        loadDependencies();

        // Deploy the defaults contract.
        defaults = new Defaults(users, dai, permit2, proxy);

        // Deploy V2 Periphery.
        deployProtocolConditionally();

        // Label the contracts.
        labelContracts();

        // Approve Permit2 to spend funds.
        approvePermit2();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Loads all dependencies pre-deployed on Goerli.
    function loadDependencies() private {
        // Load WETH.
        weth = IWrappedNativeAsset(0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6);

        // Load the proxy registry.
        registry = IPRBProxyRegistry(0x8afE5fE3BAfA1FbC941a50b630AA966F3A7815A0);

        // Load the proxy helpers.
        proxyHelpers = IPRBProxyHelpers(0x842b72D8521E9a09D229434e4E9517DB1a4fAA71);

        // Deploy a proxy for Alice.
        proxy = registry.deployFor(users.alice.addr);

        // Load Permit2.
        permit2 = IAllowanceTransfer(0x000000000022D473030F116dDEE9F6B43aC78BA3);

        // Load V2 Core.
        dynamic = ISablierV2LockupDynamic(0xD65332c5D63e93Ef6a9F4c0b5cda894E5809F9f6);
        linear = ISablierV2LockupLinear(0x93369c09b52449b4F888292b09cc8e9cEb7643Df);
    }
}
