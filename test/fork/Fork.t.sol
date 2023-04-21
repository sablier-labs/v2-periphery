// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IPRBProxyRegistry } from "@prb/proxy/interfaces/IPRBProxyRegistry.sol";
import { ISablierV2LockupDynamic } from "@sablier/v2-core/interfaces/ISablierV2LockupDynamic.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";
import { IAllowanceTransfer } from "permit2/interfaces/IAllowanceTransfer.sol";

import { IWrappedNativeAsset } from "src/interfaces/IWrappedNativeAsset.sol";

import { Defaults } from "../utils/Defaults.sol";
import { Base_Test } from "../Base.t.sol";

/// @title Fork_Test
/// @notice Tests that run against a Goerli testnet fork.
abstract contract Fork_Test is Base_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        Base_Test.setUp();

        // Fork the Goerli testnet.
        vm.createSelectFork({ blockNumber: 8_856_000, urlOrAlias: "goerli" });

        // Load the dependencies.
        loadDependencies();

        // Deploy the contract containing the default values used for testing.
        defaults = new Defaults(users, dai, proxy);

        // Deploy V2 Periphery.
        deployProtocolConditionally();

        // Approve Permit2 to spend funds.
        approvePermit2();

        // Label the contracts.
        labelContracts();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Loads all dependencies pre-deployed on Goerli.
    function loadDependencies() private {
        // Load WETH.
        weth = IWrappedNativeAsset(0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6);

        // Load the proxy registry.
        registry = IPRBProxyRegistry(0x842b72D8521E9a09D229434e4E9517DB1a4fAA71);

        // Deploy a proxy for the sender.
        proxy = registry.deployFor(users.sender.addr);

        // Load Permit2.
        permit2 = IAllowanceTransfer(0x000000000022D473030F116dDEE9F6B43aC78BA3);

        // Load V2 Core.
        dynamic = ISablierV2LockupDynamic(0xD65332c5D63e93Ef6a9F4c0b5cda894E5809F9f6);
        linear = ISablierV2LockupLinear(0x93369c09b52449b4F888292b09cc8e9cEb7643Df);
    }
}
