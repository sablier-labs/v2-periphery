// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ISablierV2LockupDynamic } from "@sablier/v2-core/src/interfaces/ISablierV2LockupDynamic.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";

import { Fuzzers as V2CoreFuzzers } from "@sablier/v2-core/test/utils/Fuzzers.sol";

import { Defaults } from "../utils/Defaults.sol";
import { Base_Test } from "../Base.t.sol";

/// @notice Common logic needed by all fork tests.
abstract contract Fork_Test is Base_Test, V2CoreFuzzers {
    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    IERC20 internal immutable ASSET;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor(IERC20 asset_) {
        ASSET = asset_;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        // Fork Blast mainnet at a specific block number.
        vm.createSelectFork({ blockNumber: 216_583, urlOrAlias: "blast" });

        // Set up the base test contract.
        Base_Test.setUp();

        // Load the external dependencies.
        loadDependencies();

        // Deploy the defaults contract and allow it to access cheatcodes.
        defaults = new Defaults(users, ASSET);
        vm.allowCheatcodes(address(defaults));

        // Deploy V2 Periphery.
        deployPeripheryConditionally();

        // Label the contracts.
        labelContracts(ASSET);

        // Approve the relevant contract.
        approveContract({ asset_: ASSET, from: users.alice, spender: address(batch) });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Checks the user assumptions.
    function checkUsers(address user, address recipient) internal virtual {
        // The protocol does not allow the zero address to interact with it.
        vm.assume(user != address(0) && recipient != address(0));

        // The goal is to not have overlapping users because the asset balance tests would fail otherwise.
        vm.assume(user != recipient);
        vm.assume(user != address(lockupDynamic) && recipient != address(lockupDynamic));
        vm.assume(user != address(lockupLinear) && recipient != address(lockupLinear));

        // Avoid users blacklisted by USDC or USDT.
        assumeNoBlacklisted(address(ASSET), user);
        assumeNoBlacklisted(address(ASSET), recipient);
    }

    /// @dev Loads all dependencies pre-deployed on Mainnet.
    function loadDependencies() private {
        lockupDynamic = ISablierV2LockupDynamic(0xf5dDFE27B49e5Ba785012c061Ee4F8B03f2f1474);
        lockupLinear = ISablierV2LockupLinear(0xE97E92B56a6a3B23775e315a4fb8a6424e5E37D6);
    }
}
