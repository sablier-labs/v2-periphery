// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { PRBProxyRegistry } from "@prb/proxy/PRBProxyRegistry.sol";
import { IAllowanceTransfer } from "permit2/interfaces/IAllowanceTransfer.sol";

import { Precompiles as PRBProxyPrecompiles } from "@prb/proxy-test/utils/Precompiles.sol";
import { Precompiles as V2CorePrecompiles } from "@sablier/v2-core-test/utils/Precompiles.sol";
import { DeployPermit2 } from "permit2-test/utils/DeployPermit2.sol";

import { Defaults } from "../shared/Defaults.t.sol";
import { WETH } from "../shared/mockups/WETH.t.sol";
import { Base_Test } from "../Base.t.sol";

/// @title Unit_Test
/// @notice Common logic needed by all unit test contracts.
abstract contract Unit_Test is Base_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        Base_Test.setUp();

        // Deploy the unit test contracts.
        deployDependencies();

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

    function deployDependencies() private {
        // Deploy WETH.
        weth = new WETH();

        // Deploy the proxy registry from a bytecode precompiled with via IR.
        registry = new PRBProxyPrecompiles().deployRegistry();

        // Deploy a proxy for the sender.
        proxy = registry.deployFor(users.sender.addr);

        // Deploy Permit2 from a bytecode precompiled with via IR.
        permit2 = IAllowanceTransfer(new DeployPermit2().run());

        // Deploy V2 Core from a bytecode precompiled with via IR.
        (, dynamic, linear) = new V2CorePrecompiles().deployProtocol(users.admin.addr);
    }
}
