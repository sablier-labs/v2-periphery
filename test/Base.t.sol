// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ERC20 } from "@openzeppelin/token/ERC20/ERC20.sol";
import { AllowanceTransfer } from "@permit2/AllowanceTransfer.sol";
import { IAllowanceTransfer } from "@permit2/interfaces/IAllowanceTransfer.sol";
import { PermitHash } from "@permit2/libraries/PermitHash.sol";
import { IPRBProxy } from "@prb/proxy/interfaces/IPRBProxy.sol";
import { PRBProxyRegistry } from "@prb/proxy/PRBProxyRegistry.sol";
import { SablierV2Lockup } from "@sablier/v2-core/abstracts/SablierV2Lockup.sol";
import { SablierV2Comptroller } from "@sablier/v2-core/SablierV2Comptroller.sol";
import { SablierV2LockupLinear } from "@sablier/v2-core/SablierV2LockupLinear.sol";
import { SablierV2LockupDynamic } from "@sablier/v2-core/SablierV2LockupDynamic.sol";
import { LockupLinear, LockupDynamic } from "@sablier/v2-core/types/DataTypes.sol";
import { StdCheats } from "forge-std/StdCheats.sol";

import { SablierV2ProxyTarget } from "src/SablierV2ProxyTarget.sol";

import { Assertions } from "./helpers/Assertions.t.sol";
import { DefaultParams } from "./helpers/DefaultParams.t.sol";
import { SablierV2NFTDescriptor } from "./mockups/SablierV2NFTDescriptor.t.sol";

/// @title Base_Test
/// @notice Base test contract with common logic needed by all test contracts.
abstract contract Base_Test is Assertions, StdCheats {
    /*//////////////////////////////////////////////////////////////////////////
                                   TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    ERC20 internal asset = new ERC20("Asset Coin", "Asset");
    AllowanceTransfer internal permit2 = new AllowanceTransfer();

    PRBProxyRegistry internal registry = new PRBProxyRegistry();
    IPRBProxy internal proxy;

    SablierV2Comptroller internal comptroller;
    SablierV2NFTDescriptor internal descriptor = new SablierV2NFTDescriptor();
    SablierV2LockupDynamic internal dynamic;
    SablierV2LockupLinear internal linear;
    SablierV2ProxyTarget internal target;

    /*//////////////////////////////////////////////////////////////////////////
                                  INTERNAL STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    DefaultParams.PrivateKeys internal privateKeys;
    DefaultParams.Users internal users;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor() {
        // Deploy the target contract.
        target = new SablierV2ProxyTarget();

        // Label all the contracts just deployed.
        vm.label({ account: address(asset), newLabel: "Asset" });
        vm.label({ account: address(registry), newLabel: "ProxyRegistry" });
        vm.label({ account: address(permit2), newLabel: "Permit2" });
        vm.label({ account: address(target), newLabel: "Target" });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual {
        (users.admin, privateKeys.admin) = createUser("Admin");
        (users.broker, privateKeys.broker) = createUser("Broker");
        (users.recipient, privateKeys.recipient) = createUser("Recipient");
        (users.sender, privateKeys.sender) = createUser("Sender");
    }

    /*//////////////////////////////////////////////////////////////////////////
                            INTERNAL CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Helper function to get the signature.
    function getPermit2Signature(
        IAllowanceTransfer.PermitDetails memory permitDetails,
        uint256 privateKey,
        address spender
    )
        internal
        view
        returns (bytes memory sig)
    {
        bytes32 permitHash = keccak256(abi.encode(PermitHash._PERMIT_DETAILS_TYPEHASH, permitDetails));
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                permit2.DOMAIN_SEPARATOR(),
                keccak256(
                    abi.encode(
                        PermitHash._PERMIT_SINGLE_TYPEHASH, permitHash, spender, DefaultParams.PERMIT2_SIG_DEADLINE
                    )
                )
            )
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);
        sig = bytes.concat(r, s, bytes1(v));
    }

    /*//////////////////////////////////////////////////////////////////////////
                          INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Helper function to approve the `permit2` contract to spend ERC-20 assets from the sender and recipient.
    function approvePermit2() internal {
        changePrank({ msgSender: users.sender });
        asset.approve({ spender: address(permit2), amount: DefaultParams.UINT256_MAX });
        changePrank({ msgSender: users.recipient });
        asset.approve({ spender: address(permit2), amount: DefaultParams.UINT256_MAX });
    }

    /// @dev Generates an address by hashing the name, labels the address and funds it with 100 ETH, 1 million assets.
    function createUser(string memory name) internal returns (address payable, uint256) {
        (address addr, uint256 privateKey) = makeAddrAndKey(name);
        vm.deal({ account: addr, newBalance: 100 ether });
        deal({ token: address(asset), to: addr, give: 1_000_000e18 });
        return (payable(addr), privateKey);
    }

    /// @dev Deploys and labels the core contracts.
    function deployCore() internal {
        comptroller = new SablierV2Comptroller(users.admin);
        linear = new SablierV2LockupLinear(users.admin, comptroller, descriptor, DefaultParams.MAX_FEE);
        dynamic =
        new SablierV2LockupDynamic(users.admin, comptroller, descriptor, DefaultParams.MAX_FEE, DefaultParams.MAX_SEGMENT_COUNT);
        vm.label({ account: address(comptroller), newLabel: "Comptroller" });
        vm.label({ account: address(dynamic), newLabel: "LockupDynamic" });
        vm.label({ account: address(linear), newLabel: "LockupLinear" });
    }

    /// @dev Expects a call to the `cancel` function of the lockup contract.
    function expectCancelCall(address lockup, uint256 streamId) internal {
        vm.expectCall(lockup, abi.encodeCall(SablierV2Lockup.cancel, (streamId)));
    }

    /// @dev Expects a call to the `cancelMultiple` function of the lockup contract.
    function expectCancelMultipleCall(address lockup, uint256[] memory streamIds) internal {
        vm.expectCall(lockup, abi.encodeCall(SablierV2Lockup.cancelMultiple, (streamIds)));
    }

    /// @dev Expects a call to the `createWithDeltas` function of the dynamic contract.
    function expectCreateWithDeltasCall(LockupDynamic.CreateWithDeltas memory params) internal {
        vm.expectCall(address(dynamic), abi.encodeCall(SablierV2LockupDynamic.createWithDeltas, (params)));
    }

    /// @dev Expects a call to the `createWithDurations` function of the linear contract.
    function expectCreateWithDurationsCall(LockupLinear.CreateWithDurations memory params) internal {
        vm.expectCall(address(linear), abi.encodeCall(SablierV2LockupLinear.createWithDurations, (params)));
    }

    /// @dev Expects a call to the `createWithMilestones` function of the dynamic contract.
    function expectCreateWithMilestonesCall(LockupDynamic.CreateWithMilestones memory params) internal {
        vm.expectCall(address(dynamic), abi.encodeCall(SablierV2LockupDynamic.createWithMilestones, (params)));
    }

    /// @dev Expects a call to the `createWithRange` function of the linear contract.
    function expectCreateWithRangeCall(LockupLinear.CreateWithRange memory params) internal {
        vm.expectCall(address(linear), abi.encodeCall(SablierV2LockupLinear.createWithRange, (params)));
    }

    /// @dev Expects `BATCH_CREATE_PARAMS_COUNT` calls to the `createWithDeltas` function of the dynamic contract.
    function expectMultipleCreateWithDeltasCalls(LockupDynamic.CreateWithDeltas memory params) internal {
        for (uint256 i = 0; i < DefaultParams.BATCH_CREATE_PARAMS_COUNT; ++i) {
            expectCreateWithDeltasCall(params);
        }
    }

    /// @dev Expects `BATCH_CREATE_PARAMS_COUNT` calls to the `createWithDurations` function of the linear contract.
    function expectMultipleCreateWithDurationsCalls(LockupLinear.CreateWithDurations memory params) internal {
        for (uint256 i = 0; i < DefaultParams.BATCH_CREATE_PARAMS_COUNT; ++i) {
            expectCreateWithDurationsCall(params);
        }
    }

    /// @dev Expects `BATCH_CREATE_PARAMS_COUNT` calls to the `createWithMilestones` function of the dynamic contract.
    function expectMultipleCreateWithMilestonesCalls(LockupDynamic.CreateWithMilestones memory params) internal {
        for (uint256 i = 0; i < DefaultParams.BATCH_CREATE_PARAMS_COUNT; ++i) {
            expectCreateWithMilestonesCall(params);
        }
    }

    /// @dev Expects `BATCH_CREATE_PARAMS_COUNT` calls to the `createWithRange` function of the linear contract.
    function expectMultipleCreateWithRangeCalls(LockupLinear.CreateWithRange memory params) internal {
        for (uint256 i = 0; i < DefaultParams.BATCH_CREATE_PARAMS_COUNT; ++i) {
            expectCreateWithRangeCall(params);
        }
    }

    /// @dev Expects `BATCH_CREATE_PARAMS_COUNT` calls to the `transfer` function of the default ERC-20 asset.
    function expectMultipleTransferCalls(address to, uint256 amount) internal {
        for (uint256 i = 0; i < DefaultParams.BATCH_CREATE_PARAMS_COUNT; ++i) {
            expectTransferCall(to, amount);
        }
    }

    /// @dev Expects `BATCH_CREATE_PARAMS_COUNT` calls to the `transferFrom` function of the default ERC-20 asset.
    function expectMultipleTransferCalls(address from, address to, uint256 amount) internal {
        for (uint256 i = 0; i < DefaultParams.BATCH_CREATE_PARAMS_COUNT; ++i) {
            expectTransferFromCall(from, to, amount);
        }
    }

    /// @dev Expects a call to the `transfer` function of the default ERC-20 asset.
    function expectTransferCall(address to, uint256 amount) internal {
        vm.expectCall(address(asset), abi.encodeCall(ERC20.transfer, (to, amount)));
    }

    /// @dev Expects a call to the `transferFrom` function of the default ERC-20 asset.
    function expectTransferFromCall(address from, address to, uint256 amount) internal {
        vm.expectCall(address(asset), abi.encodeCall(ERC20.transferFrom, (from, to, amount)));
    }
}
