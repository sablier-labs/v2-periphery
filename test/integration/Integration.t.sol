// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Precompiles as V2CorePrecompiles } from "@sablier/v2-core/test/utils/Precompiles.sol";

import { Defaults } from "../utils/Defaults.sol";
import { Base_Test } from "../Base.t.sol";
import { Blast } from "../mocks/Blast.sol";
import { Gas } from "../mocks/Gas.sol";
import { Yield } from "../mocks/Yield.sol";
import { MockUSDB } from "../mocks/MockUSDB.sol";

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

        // Set ERC20 rebasing contracts.
        setBlastContracts();

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

    function setBlastContracts() private {
        Yield yieldContract = new Yield();
        Gas gasContract = new Gas();
        Blast blast = new Blast(address(gasContract), address(yieldContract));
        bytes memory erc20RebasingCode = type(MockUSDB).creationCode;

        vm.etch(0x4300000000000000000000000000000000000002, address(blast).code);
        vm.etch(0x4200000000000000000000000000000000000022, erc20RebasingCode);
        vm.etch(0x4200000000000000000000000000000000000023, erc20RebasingCode);
    }
}
