// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <0.9.0;

import { ERC20 } from "@openzeppelin/token/ERC20/ERC20.sol";
import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { UD60x18 } from "@prb/math/UD60x18.sol";
import { PRBTest } from "@prb/test/PRBTest.sol";
import { ISablierV2Comptroller } from "@sablier/v2-core/interfaces/ISablierV2Comptroller.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";
import { ISablierV2LockupPro } from "@sablier/v2-core/interfaces/ISablierV2LockupPro.sol";
import { SablierV2Comptroller } from "@sablier/v2-core/SablierV2Comptroller.sol";
import { SablierV2LockupLinear } from "@sablier/v2-core/SablierV2LockupLinear.sol";
import { SablierV2LockupPro } from "@sablier/v2-core/SablierV2LockupPro.sol";
import { StdCheats } from "forge-std/StdCheats.sol";

import { BatchStream } from "src/BatchStream.sol";
import { IBatchStream } from "src/interfaces/IBatchStream.sol";

import { Utils } from "./helpers/Utils.t.sol";

/// @title Base_Test
/// @notice Base test contract with common logic needed by all test contracts.
abstract contract Base_Test is PRBTest, StdCheats, Utils {
    /*//////////////////////////////////////////////////////////////////////////
                                   TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    IERC20 internal asset;
    IBatchStream internal batch;
    ISablierV2Comptroller internal comptroller;
    ISablierV2LockupLinear internal linear;
    ISablierV2LockupPro internal pro;

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual {
        // Create users for testing.
        users = Users({
            admin: createUser("Admin"),
            alice: createUser("Alice"),
            broker: createUser("Broker"),
            eve: createUser("Eve"),
            recipient: createUser("Recipient"),
            sender: createUser("Sender")
        });

        // Deploy the asset to use for testing.
        asset = new ERC20("Asset Coin", "Asset");

        // Deploy the core contracts.
        comptroller = new SablierV2Comptroller(users.admin);
        linear = new SablierV2LockupLinear(users.admin, comptroller, DEFAULT_MAX_FEE);
        pro = new SablierV2LockupPro(users.admin, comptroller, DEFAULT_MAX_FEE, DEFAULT_MAX_SEGMENT_COUNT);

        // Deploy the periphery contract.
        batch = new BatchStream();

        // Label all the contracts just deployed.
        vm.label({ account: address(asset), newLabel: "Asset" });
        vm.label({ account: address(batch), newLabel: "Batch" });
        vm.label({ account: address(comptroller), newLabel: "Comptroller" });
        vm.label({ account: address(linear), newLabel: "LockupLinear" });
        vm.label({ account: address(pro), newLabel: "LockupPro" });
    }

    /*//////////////////////////////////////////////////////////////////////////
                          NON-CONSTANT INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Creates default streams.
    function createWithDeltasMultipleDefault() internal returns (uint256[] memory streamIds) {
        streamIds = batch.createWithDeltasMultiple(pro, defaultDeltasParams(), asset, DEFAULT_TOTAL_AMOUNT);
    }

    /// @dev Creates default streams.
    function createWithDurationsMultipleDefault() internal returns (uint256[] memory streamIds) {
        streamIds = batch.createWithDurationsMultiple(linear, defaultDurationsParams(), asset, DEFAULT_TOTAL_AMOUNT);
    }

    /// @dev Creates default streams.
    function createWithMilestonesMultipleDefault() internal returns (uint256[] memory streamIds) {
        streamIds = batch.createWithMilestonesMultiple(pro, defaultMilestonesParams(), asset, DEFAULT_TOTAL_AMOUNT);
    }

    /// @dev Creates default streams.
    function createWithRangeMultipleDefault() internal returns (uint256[] memory streamIds) {
        streamIds = batch.createWithRangeMultiple(linear, defaultRangeParams(), asset, DEFAULT_TOTAL_AMOUNT);
    }

    /// @dev Generates an address by hashing the name, labels the address and funds it with 100 ETH, 1 million assets,
    /// and 1 million non-compliant assets.
    function createUser(string memory name) internal returns (address payable addr) {
        addr = payable(address(uint160(uint256(keccak256(abi.encodePacked(name))))));
        vm.label({ account: addr, newLabel: name });
        vm.deal({ account: addr, newBalance: 100 ether });
        deal({ token: address(asset), to: addr, give: 1_000_000e18 });
    }
}
