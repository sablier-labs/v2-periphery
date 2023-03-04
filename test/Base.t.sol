// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ERC20 } from "@openzeppelin/token/ERC20/ERC20.sol";
import { AllowanceTransfer } from "@permit2/AllowanceTransfer.sol";
import { IAllowanceTransfer } from "@permit2/interfaces/IAllowanceTransfer.sol";
import { PRBTest } from "@prb/test/PRBTest.sol";
import { SablierV2Comptroller } from "@sablier/v2-core/SablierV2Comptroller.sol";
import { SablierV2LockupLinear } from "@sablier/v2-core/SablierV2LockupLinear.sol";
import { SablierV2LockupPro } from "@sablier/v2-core/SablierV2LockupPro.sol";
import { StdCheats } from "forge-std/StdCheats.sol";

import { SablierV2ProxyTarget } from "src/SablierV2ProxyTarget.sol";

import { SablierV2NftDescriptor } from "./mockups/SablierV2NftDescriptor.t.sol";
import { Constants } from "./helpers/Constants.t.sol";

/// @title Base_Test
/// @notice Base test contract with common logic needed by all test contracts.
abstract contract Base_Test is Constants, PRBTest, StdCheats {
    /*//////////////////////////////////////////////////////////////////////////
                                   TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    ERC20 internal asset;
    AllowanceTransfer internal permit2;

    SablierV2Comptroller internal comptroller;
    SablierV2NftDescriptor internal descriptor;
    SablierV2LockupLinear internal linear;
    SablierV2LockupPro internal pro;
    SablierV2ProxyTarget internal target;

    /*//////////////////////////////////////////////////////////////////////////
                                  INTERNAL STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    struct PrivateKeys {
        uint256 admin;
        uint256 alice;
        uint256 broker;
        uint256 eve;
        uint256 recipient;
        uint256 sender;
    }

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

    IAllowanceTransfer.PermitDetails internal defaultPermitDetails;
    PrivateKeys internal privateKeys;
    Users internal users;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor() {
        // Deploy the asset to use for testing.
        asset = new ERC20("Asset Coin", "Asset");

        // Deploy the permit2 contract.
        permit2 = new AllowanceTransfer();

        // Deploy the core contracts.
        comptroller = new SablierV2Comptroller(users.admin);
        descriptor = new SablierV2NftDescriptor();
        linear = new SablierV2LockupLinear(users.admin, comptroller, descriptor, DEFAULT_MAX_FEE);
        pro = new SablierV2LockupPro(users.admin, comptroller, descriptor, DEFAULT_MAX_FEE, DEFAULT_MAX_SEGMENT_COUNT);

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
        (users.admin, privateKeys.admin) = createUser("Admin");
        (users.alice, privateKeys.alice) = createUser("Alice");
        (users.broker, privateKeys.broker) = createUser("Broker");
        (users.eve, privateKeys.eve) = createUser("Eve");
        (users.recipient, privateKeys.recipient) = createUser("Recipient");
        (users.sender, privateKeys.sender) = createUser("Sender");

        defaultPermitDetails = IAllowanceTransfer.PermitDetails({
            token: address(asset),
            amount: UINT160_MAX,
            expiration: DEFAULT_PERMIT2_EXPIRATION,
            nonce: DEFAULT_PERMIT2_NONCE
        });
    }

    /*//////////////////////////////////////////////////////////////////////////
                            INTERNAL CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Helper function to get the `PermitSingle` struct given the `spender`.
    function getPermitSingle(address spender) internal view returns (IAllowanceTransfer.PermitSingle memory permit) {
        permit = IAllowanceTransfer.PermitSingle({
            details: defaultPermitDetails,
            spender: spender,
            sigDeadline: DEFAULT_PERMIT2_SIG_DEADLINE
        });
    }

    /// @dev Helper function to get the signature given the `spender` and the `privateKey`.
    function getPermitSignature(address spender, uint256 privateKey) internal view returns (bytes memory sig) {
        bytes32 permitHash = keccak256(abi.encode(PERMIT_DETAILS_TYPEHASH, defaultPermitDetails));
        bytes32 msgHash = keccak256(
            abi.encodePacked(
                "\x19\x01",
                permit2.DOMAIN_SEPARATOR(),
                keccak256(abi.encode(PERMIT_SINGLE_TYPEHASH, permitHash, spender, DEFAULT_PERMIT2_SIG_DEADLINE))
            )
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, msgHash);
        sig = bytes.concat(r, s, bytes1(v));
    }

    /*//////////////////////////////////////////////////////////////////////////
                          INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Helper function to approve the `permit2` contract to spend ERC-20 assets from
    /// the sender, recipient, Alice and Eve.
    function approvePermit2() internal {
        changePrank({ msgSender: users.sender });
        asset.approve({ spender: address(permit2), amount: UINT256_MAX });
        changePrank({ msgSender: users.recipient });
        asset.approve({ spender: address(permit2), amount: UINT256_MAX });
        changePrank({ msgSender: users.alice });
        asset.approve({ spender: address(permit2), amount: UINT256_MAX });
        changePrank({ msgSender: users.eve });
        asset.approve({ spender: address(permit2), amount: UINT256_MAX });
    }

    function permitTarget() internal {
        changePrank({ msgSender: users.alice });
        permit2.permit(
            users.alice,
            getPermitSingle(address(target)),
            getPermitSignature(address(target), privateKeys.alice)
        );
        changePrank({ msgSender: users.eve });
        permit2.permit(
            users.eve,
            getPermitSingle(address(target)),
            getPermitSignature(address(target), privateKeys.eve)
        );
        changePrank({ msgSender: users.recipient });
        permit2.permit(
            users.recipient,
            getPermitSingle(address(target)),
            getPermitSignature(address(target), privateKeys.recipient)
        );
        changePrank({ msgSender: users.sender });
        permit2.permit(
            users.sender,
            getPermitSingle(address(target)),
            getPermitSignature(address(target), privateKeys.sender)
        );
    }

    /// @dev Generates an address by hashing the name, labels the address and funds it with 100 ETH, 1 million assets,
    /// and 1 million non-compliant assets.
    function createUser(string memory name) internal returns (address payable, uint256) {
        (address addr, uint256 privateKey) = makeAddrAndKey(name);
        vm.deal({ account: addr, newBalance: 100 ether });
        deal({ token: address(asset), to: addr, give: 1_000_000e18 });
        return (payable(addr), privateKey);
    }

    /// @dev Expects a call to the `transfer` function of the default ERC-20 asset.
    function expectTransferFromCall(address from, address to, uint256 amount) internal {
        vm.expectCall(address(asset), abi.encodeCall(ERC20.transferFrom, (from, to, amount)));
    }

    /// @dev Expects multiple calls to the `transfer` function of the default ERC-20 asset.
    function expectTransferFromCallMutiple(address from, address to, uint256 amount) internal {
        for (uint256 i = 0; i < PARAMS_COUNT; ++i) {
            expectTransferFromCall(from, to, amount);
        }
    }
}
