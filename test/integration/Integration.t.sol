// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { PRBProxyRegistry } from "@prb/proxy/PRBProxyRegistry.sol";
import { IAllowanceTransfer } from "permit2/interfaces/IAllowanceTransfer.sol";

import { Precompiles as PRBProxyPrecompiles } from "@prb/proxy-test/utils/Precompiles.sol";
import { Precompiles as V2CorePrecompiles } from "@sablier/v2-core-test/utils/Precompiles.sol";
import { DeployPermit2 } from "permit2-test/utils/DeployPermit2.sol";

import { Defaults } from "../utils/Defaults.sol";
import { WETH } from "../mocks/WETH.sol";
import { Base_Test } from "../Base.t.sol";

/// @notice Common logic needed by all integration tests.
abstract contract Integration_Test is Base_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        Base_Test.setUp();

        // Deploy the external dependencies.
        deployDependencies();

        // Deploy the defaults contract.
        defaults = new Defaults(users, dai, permit2, proxy);

        // Deploy V2 Periphery.
        deployPeripheryConditionally();

        // Label the contracts.
        labelContracts();

        // Approve Permit2 to spend funds.
        approvePermit2();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function deployDependencies() private {
        // Deploy WETH.
        weth = new WETH();

        // Deploy the proxy system from a bytecode precompiled with `--via-ir`.
        (proxyAnnex, proxyRegistry) = new PRBProxyPrecompiles().deploySystem();

        // Deploy a proxy for Alice.
        proxy = proxyRegistry.deployFor(users.alice.addr);

        // Deploy Permit2 from a bytecode precompiled with `--via-ir`.
        permit2 = IAllowanceTransfer(new DeployPermit2().run());

        // Deploy V2 Core from a bytecode precompiled with `--via-ir`.
        (, dynamic, linear,) = new V2CorePrecompiles().deployCore(users.admin.addr);
    }
}
