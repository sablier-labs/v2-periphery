// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { PRBProxyRegistry } from "@prb/proxy/PRBProxyRegistry.sol";
import { DeployProtocol as DeployCoreProtocol } from "@sablier/v2-core-script/deploy/DeployProtocol.s.sol";
import { IAllowanceTransfer } from "permit2/interfaces/IAllowanceTransfer.sol";

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
        deployContracts();

        // Approve Permit2 to spend funds.
        approvePermit2();

        // Label the contracts.
        labelContracts();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function deployContracts() private {
        // Deploy WETH.
        weth = new WETH();

        // Deploy the proxy registry and deploy a proxy for the sender.
        registry = new PRBProxyRegistry();
        proxy = registry.deployFor(users.sender.addr);

        // Deploy the contract containing the default values used for testing.
        defaults = new Defaults(users, dai, proxy);

        // Deploy Permit2 from a source precompiled with via IR.
        permit2 = IAllowanceTransfer(new DeployPermit2().run());

        // Deploy V2 Core.
        (, linear, dynamic) = new DeployCoreProtocol().run({
            initialAdmin: users.admin.addr,
            initialNFTDescriptor: nftDescriptor,
            maxSegmentCount: defaults.MAX_SEGMENT_COUNT()
        });

        // Deploy V2 Periphery.
        deployProtocolConditionally();
    }
}
