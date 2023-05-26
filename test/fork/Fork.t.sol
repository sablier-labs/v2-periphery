// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { IPRBProxyAnnex } from "@prb/proxy/interfaces/IPRBProxyAnnex.sol";
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
                                     CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    IERC20 internal immutable asset;

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
        vm.createSelectFork({ blockNumber: 9_056_572, urlOrAlias: "goerli" });

        // The base is set up after the fork is selected so that the base test contracts are deployed on the fork.
        Base_Test.setUp();

        // Load the dependencies.
        loadDependencies();

        // Deploy the defaults contract.
        defaults = new Defaults(users, asset, permit2, proxy);

        // Deploy V2 Periphery.
        deployProtocolConditionally();

        // Label the contracts.
        labelContracts();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Checks the user assumptions.
    function checkUsers(address sender, address recipient) internal virtual {
        // The protocol does not allow the zero address to interact with it.
        vm.assume(sender != address(0) && recipient != address(0));

        // The goal is to not have overlapping users because the token balance tests would fail otherwise.
        vm.assume(sender != recipient && sender != users.broker.addr && recipient != users.broker.addr);
        vm.assume(sender != address(proxy) && recipient != address(proxy));
        vm.assume(sender != address(dynamic) && recipient != address(dynamic));
        vm.assume(sender != address(linear) && recipient != address(linear));
    }

    /// @dev Loads all dependencies pre-deployed on Goerli.
    function loadDependencies() private {
        // Load WETH.
        weth = IWrappedNativeAsset(0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6);

        // Load the proxy annex.
        proxyAnnex = IPRBProxyAnnex(0x842b72D8521E9a09D229434e4E9517DB1a4fAA71);

        // Load the proxy registry.
        proxyRegistry = IPRBProxyRegistry(0x8afE5fE3BAfA1FbC941a50b630AA966F3A7815A0);

        // Load Permit2.
        permit2 = IAllowanceTransfer(0x000000000022D473030F116dDEE9F6B43aC78BA3);

        // Load V2 Core.
        dynamic = ISablierV2LockupDynamic(0x4a57C183333a0a81300259d1795836fA0F4863BB);
        linear = ISablierV2LockupLinear(0xd78D4FE35779342d5FE2E8206d886D57139d6abB);
    }
}
