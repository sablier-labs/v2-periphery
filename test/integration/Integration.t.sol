// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IAllowanceTransfer } from "permit2/interfaces/IAllowanceTransfer.sol";

import { Precompiles as PRBProxyPrecompiles } from "@prb/proxy-test/utils/Precompiles.sol";
import { Precompiles as V2CorePrecompiles } from "@sablier/v2-core-test/utils/Precompiles.sol";
import { DeployPermit2 } from "permit2-test/utils/DeployPermit2.sol";

import { Defaults } from "../utils/Defaults.sol";
import { WETH } from "../mocks/WETH.sol";
import { WLC } from "../mocks/WLC.sol";
import { Base_Test } from "../Base.t.sol";

/// @notice Common logic needed by all integration tests.
abstract contract Integration_Test is Base_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        // Deploy the default test asset.
        asset = new ERC20("DAI Stablecoin", "DAI");

        // Set up the base test contract.
        Base_Test.setUp();

        // Deploy the external dependencies.
        deployDependencies();

        // Deploy the defaults contract.
        defaults = new Defaults(users, asset, permit2, aliceProxy);

        // Deploy V2 Periphery.
        deployPeripheryConditionally();

        // Label the contracts.
        labelContracts();

        // Approve Permit2 to spend assets from the stream's recipient and Alice (the proxy owner).
        vm.startPrank({ msgSender: users.recipient.addr });
        asset.approve({ spender: address(permit2), amount: MAX_UINT256 });

        changePrank({ msgSender: users.alice.addr });
        asset.approve({ spender: address(permit2), amount: MAX_UINT256 });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function deployDependencies() private {
        weth = new WETH();
        wlc = new WLC();
        proxyRegistry = new PRBProxyPrecompiles().deployRegistry();
        aliceProxy = proxyRegistry.deployFor(users.alice.addr);
        permit2 = IAllowanceTransfer(new DeployPermit2().run());
        (, lockupDynamic, lockupLinear,) = new V2CorePrecompiles().deployCore(users.admin.addr);
    }
}
