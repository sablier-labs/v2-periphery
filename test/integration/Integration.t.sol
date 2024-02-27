// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Precompiles as V2CorePrecompiles } from "@sablier/v2-core/test/utils/Precompiles.sol";

import { Defaults } from "../utils/Defaults.sol";
import { Base_Test } from "../Base.t.sol";
import { BlastMock } from "../mocks/blast/BlastMock.sol";

import { console2 } from "forge-std/src/console2.sol";

/// @notice Common logic needed by all integration tests.
abstract contract Integration_Test is Base_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        // Set up the base test contract.
        Base_Test.setUp();

        // Deploy the external dependencies.
        deployDependencies();

        // Deploy the defaults contract.
        defaults = new Defaults(users, dai);

        // Set Blast contract.
        setBlastContract();

        // Deploy V2 Periphery.
        deployPeripheryConditionally();

        // Label the contracts.
        labelContracts(dai);

        // Approve the relevant contracts.
        approveContract({ asset_: dai, from: users.alice, spender: address(batch) });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function deployDependencies() private {
        (comptroller, lockupDynamic, lockupLinear,) = new V2CorePrecompiles().deployCore(users.admin);
    }

    function setBlastContract() private {
        BlastMock blast = BlastMock(0x4300000000000000000000000000000000000002);

        // Deploys BlastMock contract and sets the bytecode to the blast address.
        vm.etch(address(blast), address(new BlastMock()).code);

        // Overwrites storage slot of GasMock and YieldMock contracts. This is necessary because these contracts can
        // only be called by the BlastMock contract.
        vm.store(address(blast.GAS()), bytes32(uint256(0)), bytes32(uint256(uint160(address(blast)))));
        vm.store(address(blast.YIELD()), bytes32(uint256(0)), bytes32(uint256(uint160(address(blast)))));
    }
}
