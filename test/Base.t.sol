// SPDX-License-Identifier: UNLICENSED
// solhint-disable max-states-count
pragma solidity >=0.8.22 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { ISablierV2Comptroller } from "@sablier/v2-core/src/interfaces/ISablierV2Comptroller.sol";
import { ISablierV2LockupDynamic } from "@sablier/v2-core/src/interfaces/ISablierV2LockupDynamic.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { ISablierV2LockupTranched } from "@sablier/v2-core/src/interfaces/ISablierV2LockupTranched.sol";
import { LockupDynamic, LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { Assertions as V2CoreAssertions } from "@sablier/v2-core/test/utils/Assertions.sol";
import { Utils as V2CoreUtils } from "@sablier/v2-core/test/utils/Utils.sol";

import { ISablierV2Batch } from "src/interfaces/ISablierV2Batch.sol";
import { ISablierV2MerkleLockupFactory } from "src/interfaces/ISablierV2MerkleLockupFactory.sol";
import { ISablierV2MerkleLockupLL } from "src/interfaces/ISablierV2MerkleLockupLL.sol";
import { ISablierV2MerkleLockupLT } from "src/interfaces/ISablierV2MerkleLockupLT.sol";
import { SablierV2Batch } from "src/SablierV2Batch.sol";
import { SablierV2MerkleLockupFactory } from "src/SablierV2MerkleLockupFactory.sol";
import { SablierV2MerkleLockupLL } from "src/SablierV2MerkleLockupLL.sol";
import { SablierV2MerkleLockupLT } from "src/SablierV2MerkleLockupLT.sol";

import { ERC20Mock } from "./mocks/erc20/ERC20Mock.sol";
import { Assertions } from "./utils/Assertions.sol";
import { Defaults } from "./utils/Defaults.sol";
import { DeployOptimized } from "./utils/DeployOptimized.sol";
import { Events } from "./utils/Events.sol";
import { Merkle } from "./utils/Murky.sol";
import { Users } from "./utils/Types.sol";

/// @notice Base test contract with common logic needed by all tests.
abstract contract Base_Test is Assertions, DeployOptimized, Events, Merkle, V2CoreAssertions, V2CoreUtils {
    /*//////////////////////////////////////////////////////////////////////////
                                     VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    Users internal users;

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    IERC20 internal dai;
    ISablierV2Batch internal batch;
    ISablierV2Comptroller internal comptroller;
    Defaults internal defaults;
    ISablierV2LockupDynamic internal lockupDynamic;
    ISablierV2LockupLinear internal lockupLinear;
    ISablierV2LockupTranched internal lockupTranched;
    ISablierV2MerkleLockupFactory internal merkleLockupFactory;
    ISablierV2MerkleLockupLL internal merkleLockupLL;
    ISablierV2MerkleLockupLT internal merkleLockupLT;

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual {
        // Deploy the default test asset.
        dai = new ERC20Mock("DAI Stablecoin", "DAI");

        // Create users for testing.
        users.alice = createUser("Alice");
        users.admin = createUser("Admin");
        users.broker = createUser("Broker");
        users.eve = createUser("Eve");
        users.recipient0 = createUser("Recipient");
        users.recipient1 = createUser("Recipient1");
        users.recipient2 = createUser("Recipient2");
        users.recipient3 = createUser("Recipient3");
        users.recipient4 = createUser("Recipient4");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Approve contract to spend asset from some users.
    function approveContract(IERC20 asset_, address from, address spender) internal {
        changePrank({ msgSender: from });
        (bool success,) = address(asset_).call(abi.encodeCall(IERC20.approve, (spender, MAX_UINT256)));
        success;
    }

    /// @dev Generates a user, labels its address, and funds it with ETH.
    function createUser(string memory name) internal returns (address payable) {
        address user = makeAddr(name);
        vm.deal({ account: user, newBalance: 100_000 ether });
        deal({ token: address(dai), to: user, give: 1_000_000e18 });
        return payable(user);
    }

    /// @dev Conditionally deploy V2 Periphery normally or from an optimized source compiled with `--via-ir`.
    function deployPeripheryConditionally() internal {
        if (!isTestOptimizedProfile()) {
            batch = new SablierV2Batch();
            merkleLockupFactory = new SablierV2MerkleLockupFactory();
        } else {
            (batch, merkleLockupFactory) = deployOptimizedPeriphery();
        }
    }

    /// @dev Labels the most relevant contracts.
    function labelContracts(IERC20 asset_) internal {
        vm.label({ account: address(asset_), newLabel: IERC20Metadata(address(asset_)).symbol() });
        vm.label({ account: address(merkleLockupFactory), newLabel: "MerkleLockupFactory" });
        vm.label({ account: address(merkleLockupLL), newLabel: "MerkleLockupLL" });
        vm.label({ account: address(defaults), newLabel: "Defaults" });
        vm.label({ account: address(comptroller), newLabel: "Comptroller" });
        vm.label({ account: address(lockupDynamic), newLabel: "LockupDynamic" });
        vm.label({ account: address(lockupLinear), newLabel: "LockupLinear" });
        vm.label({ account: address(lockupTranched), newLabel: "LockupTranched" });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    CALL EXPECTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Expects a call to {ISablierV2LockupDynamic.createWithDurations}.
    function expectCallToCreateWithDurationsLD(LockupDynamic.CreateWithDurations memory params) internal {
        vm.expectCall({
            callee: address(lockupDynamic),
            data: abi.encodeCall(ISablierV2LockupDynamic.createWithDurations, (params))
        });
    }

    /// @dev Expects a call to {ISablierV2LockupLinear.createWithDurations}.
    function expectCallToCreateWithDurationsLL(LockupLinear.CreateWithDurations memory params) internal {
        vm.expectCall({
            callee: address(lockupLinear),
            data: abi.encodeCall(ISablierV2LockupLinear.createWithDurations, (params))
        });
    }

    /// @dev Expects a call to {ISablierV2LockupDynamic.createWithTimestamps}.
    function expectCallToCreateWithTimestampsLD(LockupDynamic.CreateWithTimestamps memory params) internal {
        vm.expectCall({
            callee: address(lockupDynamic),
            data: abi.encodeCall(ISablierV2LockupDynamic.createWithTimestamps, (params))
        });
    }

    /// @dev Expects a call to {ISablierV2LockupLinear.createWithTimestamps}.
    function expectCallToCreateWithTimestampsLL(LockupLinear.CreateWithTimestamps memory params) internal {
        vm.expectCall({
            callee: address(lockupLinear),
            data: abi.encodeCall(ISablierV2LockupLinear.createWithTimestamps, (params))
        });
    }

    /// @dev Expects a call to {IERC20.transfer}.
    function expectCallToTransfer(address to, uint256 amount) internal {
        expectCallToTransfer(address(dai), to, amount);
    }

    /// @dev Expects a call to {IERC20.transfer}.
    function expectCallToTransfer(address asset_, address to, uint256 amount) internal {
        vm.expectCall({ callee: asset_, data: abi.encodeCall(IERC20.transfer, (to, amount)) });
    }

    /// @dev Expects a call to {IERC20.transferFrom}.
    function expectCallToTransferFrom(address from, address to, uint256 amount) internal {
        expectCallToTransferFrom(address(dai), from, to, amount);
    }

    /// @dev Expects a call to {IERC20.transferFrom}.
    function expectCallToTransferFrom(address asset_, address from, address to, uint256 amount) internal {
        vm.expectCall({ callee: asset_, data: abi.encodeCall(IERC20.transferFrom, (from, to, amount)) });
    }

    /// @dev Expects multiple calls to {ISablierV2LockupDynamic.createWithDurations}, each with the specified
    /// `params`.
    function expectMultipleCallsToCreateWithDurationsLD(
        uint64 count,
        LockupDynamic.CreateWithDurations memory params
    )
        internal
    {
        vm.expectCall({
            callee: address(lockupDynamic),
            count: count,
            data: abi.encodeCall(ISablierV2LockupDynamic.createWithDurations, (params))
        });
    }

    /// @dev Expects multiple calls to {ISablierV2LockupLinear.createWithDurations}, each with the specified
    /// `params`.
    function expectMultipleCallsToCreateWithDurationsLL(
        uint64 count,
        LockupLinear.CreateWithDurations memory params
    )
        internal
    {
        vm.expectCall({
            callee: address(lockupLinear),
            count: count,
            data: abi.encodeCall(ISablierV2LockupLinear.createWithDurations, (params))
        });
    }

    /// @dev Expects multiple calls to {ISablierV2LockupDynamic.createWithTimestamps}, each with the specified
    /// `params`.
    function expectMultipleCallsToCreateWithTimestampsLD(
        uint64 count,
        LockupDynamic.CreateWithTimestamps memory params
    )
        internal
    {
        vm.expectCall({
            callee: address(lockupDynamic),
            count: count,
            data: abi.encodeCall(ISablierV2LockupDynamic.createWithTimestamps, (params))
        });
    }

    /// @dev Expects multiple calls to {ISablierV2LockupLinear.createWithTimestamps}, each with the specified
    /// `params`.
    function expectMultipleCallsToCreateWithTimestampsLL(
        uint64 count,
        LockupLinear.CreateWithTimestamps memory params
    )
        internal
    {
        vm.expectCall({
            callee: address(lockupLinear),
            count: count,
            data: abi.encodeCall(ISablierV2LockupLinear.createWithTimestamps, (params))
        });
    }

    /// @dev Expects multiple calls to {IERC20.transfer}.
    function expectMultipleCallsToTransfer(uint64 count, address to, uint256 amount) internal {
        vm.expectCall({ callee: address(dai), count: count, data: abi.encodeCall(IERC20.transfer, (to, amount)) });
    }

    /// @dev Expects multiple calls to {IERC20.transferFrom}.
    function expectMultipleCallsToTransferFrom(uint64 count, address from, address to, uint256 amount) internal {
        expectMultipleCallsToTransferFrom(address(dai), count, from, to, amount);
    }

    /// @dev Expects multiple calls to {IERC20.transferFrom}.
    function expectMultipleCallsToTransferFrom(
        address asset_,
        uint64 count,
        address from,
        address to,
        uint256 amount
    )
        internal
    {
        vm.expectCall({ callee: asset_, count: count, data: abi.encodeCall(IERC20.transferFrom, (from, to, amount)) });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  MERKLE-LOCKUP
    //////////////////////////////////////////////////////////////////////////*/

    function computeMerkleLockupLLAddress(
        address admin,
        bytes32 merkleRoot,
        uint40 expiration
    )
        internal
        returns (address)
    {
        return computeMerkleLockupLLAddress(admin, dai, merkleRoot, expiration);
    }

    function computeMerkleLockupLLAddress(
        address admin,
        IERC20 asset_,
        bytes32 merkleRoot,
        uint40 expiration
    )
        internal
        returns (address)
    {
        bytes32 salt = keccak256(
            abi.encodePacked(
                admin,
                address(asset_),
                abi.encode(defaults.IPFS_CID()),
                defaults.NAME_BYTES32(),
                merkleRoot,
                expiration,
                defaults.CANCELABLE(),
                defaults.TRANSFERABLE(),
                lockupLinear,
                abi.encode(defaults.durations())
            )
        );
        bytes32 creationBytecodeHash = keccak256(getMerkleLockupLLBytecode(admin, asset_, merkleRoot, expiration));
        return computeCreate2Address({
            salt: salt,
            initcodeHash: creationBytecodeHash,
            deployer: address(merkleLockupFactory)
        });
    }

    function computeMerkleLockupLTAddress(
        address admin,
        bytes32 merkleRoot,
        uint40 expiration
    )
        internal
        returns (address)
    {
        return computeMerkleLockupLTAddress(admin, dai, merkleRoot, expiration);
    }

    function computeMerkleLockupLTAddress(
        address admin,
        IERC20 asset_,
        bytes32 merkleRoot,
        uint40 expiration
    )
        internal
        returns (address)
    {
        bytes32 salt = keccak256(
            abi.encodePacked(
                admin,
                address(asset_),
                abi.encode(defaults.IPFS_CID()),
                defaults.NAME_BYTES32(),
                merkleRoot,
                expiration,
                defaults.CANCELABLE(),
                defaults.TRANSFERABLE(),
                lockupTranched,
                abi.encode(defaults.tranchesWithPercentages())
            )
        );
        bytes32 creationBytecodeHash = keccak256(getMerkleLockupLTBytecode(admin, asset_, merkleRoot, expiration));
        return computeCreate2Address({
            salt: salt,
            initcodeHash: creationBytecodeHash,
            deployer: address(merkleLockupFactory)
        });
    }

    function getMerkleLockupLLBytecode(
        address admin,
        IERC20 asset_,
        bytes32 merkleRoot,
        uint40 expiration
    )
        internal
        returns (bytes memory)
    {
        bytes memory constructorArgs =
            abi.encode(defaults.baseParams(admin, asset_, merkleRoot, expiration), lockupLinear, defaults.durations());
        if (!isTestOptimizedProfile()) {
            return bytes.concat(type(SablierV2MerkleLockupLL).creationCode, constructorArgs);
        } else {
            return bytes.concat(
                vm.getCode("out-optimized/SablierV2MerkleLockupLL.sol/SablierV2MerkleLockupLL.json"), constructorArgs
            );
        }
    }

    function getMerkleLockupLTBytecode(
        address admin,
        IERC20 asset_,
        bytes32 merkleRoot,
        uint40 expiration
    )
        internal
        returns (bytes memory)
    {
        bytes memory constructorArgs = abi.encode(
            defaults.baseParams(admin, asset_, merkleRoot, expiration),
            lockupTranched,
            defaults.tranchesWithPercentages()
        );
        if (!isTestOptimizedProfile()) {
            return bytes.concat(type(SablierV2MerkleLockupLT).creationCode, constructorArgs);
        } else {
            return bytes.concat(
                vm.getCode("out-optimized/SablierV2MerkleLockupLT.sol/SablierV2MerkleLockupLT.json"), constructorArgs
            );
        }
    }
}
