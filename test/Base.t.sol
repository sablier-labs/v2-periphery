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

import { SablierV2ProxyTarget } from "src/SablierV2ProxyTarget.sol";

import { Constants } from "./helpers/Constants.t.sol";

/// @title Base_Test
/// @notice Base test contract with common logic needed by all test contracts.
abstract contract Base_Test is Constants, PRBTest, StdCheats {
    /*//////////////////////////////////////////////////////////////////////////
                                   TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    IERC20 internal asset;
    ISablierV2Comptroller internal comptroller;
    ISablierV2LockupLinear internal linear;
    ISablierV2LockupPro internal pro;
    SablierV2ProxyTarget internal target;

    /*//////////////////////////////////////////////////////////////////////////
                                  INTERNAL STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    struct Users {
        // Default admin of all Sablier V2 contracts.
        address payable admin;
        // Neutral user.
        address payable alice;
        // Default stream broker.
        address payable broker;
        // Malicious user.
        address payable eve;
        // Default stream recipient.
        address payable recipient;
        // Default stream sender.
        address payable sender;
    }

    Users internal users;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor() {
        // Deploy the asset to use for testing.
        asset = new ERC20("Asset Coin", "Asset");

        // Deploy the core contracts.
        comptroller = new SablierV2Comptroller(users.admin);
        linear = new SablierV2LockupLinear(users.admin, comptroller, DEFAULT_MAX_FEE);
        pro = new SablierV2LockupPro(users.admin, comptroller, DEFAULT_MAX_FEE, DEFAULT_MAX_SEGMENT_COUNT);

        // Deploy the periphery contract.
        target = new SablierV2ProxyTarget();

        // Label all the contracts just deployed.
        vm.label({ account: address(asset), newLabel: "Asset" });
        vm.label({ account: address(comptroller), newLabel: "Comptroller" });
        vm.label({ account: address(linear), newLabel: "LockupLinear" });
        vm.label({ account: address(pro), newLabel: "LockupPro" });
        vm.label({ account: address(target), newLabel: "target" });
    }

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
    }

    /*//////////////////////////////////////////////////////////////////////////
                          INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Helper function to approve the `SablierV2ProxyTarget` contract to spend ERC-20 assets from
    /// the sender, recipient, Alice and Eve.
    function approveTarget() internal {
        changePrank({ msgSender: users.alice });
        asset.approve({ spender: address(target), amount: UINT256_MAX });

        changePrank({ msgSender: users.eve });
        asset.approve({ spender: address(target), amount: UINT256_MAX });

        changePrank({ msgSender: users.recipient });
        asset.approve({ spender: address(target), amount: UINT256_MAX });

        changePrank({ msgSender: users.sender });
        asset.approve({ spender: address(target), amount: UINT256_MAX });
    }

    /// @dev Generates an address by hashing the name, labels the address and funds it with 100 ETH, 1 million assets,
    /// and 1 million non-compliant assets.
    function createUser(string memory name) internal returns (address payable addr) {
        addr = payable(address(uint160(uint256(keccak256(abi.encodePacked(name))))));
        vm.label({ account: addr, newLabel: name });
        vm.deal({ account: addr, newBalance: 100 ether });
        deal({ token: address(asset), to: addr, give: 1_000_000e18 });
    }

    /// @dev Expects a call to the `transfer` function of the default ERC-20 asset.
    function expectTransferFromCall(address from, address to, uint256 amount) internal {
        vm.expectCall(address(asset), abi.encodeCall(IERC20.transferFrom, (from, to, amount)));
    }

    /// @dev Expects multiple calls to the `transfer` function of the default ERC-20 asset.
    function expectTransferFromCallMutiple(address from, address to, uint256 amount) internal {
        for (uint256 i = 0; i < PARAMS_COUNT; ++i) {
            expectTransferFromCall(from, to, amount);
        }
    }
}
