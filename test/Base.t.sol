// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { ERC20 } from "@openzeppelin/token/ERC20/ERC20.sol";
import { IPRBProxy } from "@prb/proxy/interfaces/IPRBProxy.sol";
import { IPRBProxyHelpers } from "@prb/proxy/interfaces/IPRBProxyHelpers.sol";
import { IPRBProxyRegistry } from "@prb/proxy/interfaces/IPRBProxyRegistry.sol";
import { ISablierV2Lockup } from "@sablier/v2-core/interfaces/ISablierV2Lockup.sol";
import { ISablierV2LockupDynamic } from "@sablier/v2-core/interfaces/ISablierV2LockupDynamic.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";
import { ISablierV2NFTDescriptor } from "@sablier/v2-core/interfaces/ISablierV2NFTDescriptor.sol";
import { SablierV2NFTDescriptor } from "@sablier/v2-core/SablierV2NFTDescriptor.sol";
import { LockupDynamic, LockupLinear } from "@sablier/v2-core/types/DataTypes.sol";
import { IAllowanceTransfer } from "permit2/interfaces/IAllowanceTransfer.sol";
import { PermitHash } from "permit2/libraries/PermitHash.sol";

import { eqString } from "@prb/test/Helpers.sol";
import { StdCheats } from "forge-std/StdCheats.sol";

import { DeployProxyPlugin } from "script/DeployProxyPlugin.s.sol";
import { DeployProxyTarget } from "script/DeployProxyTarget.s.sol";
import { ISablierV2ProxyTarget } from "src/interfaces/ISablierV2ProxyTarget.sol";
import { IWrappedNativeAsset } from "src/interfaces/IWrappedNativeAsset.sol";
import { SablierV2ProxyPlugin } from "src/SablierV2ProxyPlugin.sol";
import { Permit2Params } from "src/types/DataTypes.sol";

import { Assertions } from "./utils/Assertions.sol";
import { Defaults } from "./utils/Defaults.sol";
import { Users } from "./utils/Types.sol";

/// @title Base_Test
/// @notice Base test contract with common logic needed by all test contracts.
abstract contract Base_Test is Assertions, StdCheats {
    /*//////////////////////////////////////////////////////////////////////////
                                     VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    Users internal users;

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    IERC20 internal usdc = new ERC20("USD Coin", "USDC");
    Defaults internal defaults;
    ISablierV2LockupDynamic internal dynamic;
    ISablierV2LockupLinear internal linear;
    ISablierV2NFTDescriptor internal nftDescriptor = new SablierV2NFTDescriptor();
    IAllowanceTransfer internal permit2;
    SablierV2ProxyPlugin internal plugin;
    IPRBProxy internal proxy;
    IPRBProxyHelpers internal proxyHelpers;
    IPRBProxyRegistry internal registry;
    ISablierV2ProxyTarget internal target;
    IWrappedNativeAsset internal weth;

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual {
        users.admin = createUser("Admin");
        users.broker = createUser("Broker");
        users.recipient = createUser("Recipient");
        users.sender = createUser("Sender");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Approves Permit2 to spend assets from the recipient and the sender.
    function approvePermit2() internal {
        vm.startPrank({ msgSender: users.recipient.addr });
        usdc.approve({ spender: address(permit2), amount: MAX_UINT256 });

        changePrank({ msgSender: users.sender.addr });
        usdc.approve({ spender: address(permit2), amount: MAX_UINT256 });
    }

    /// @dev Generates a user, labels its address, and funds it with test assets.
    function createUser(string memory name) internal returns (Account memory user) {
        user = makeAccount(name);
        vm.deal({ account: user.addr, newBalance: 100_000 ether });
        deal({ token: address(usdc), to: user.addr, give: 1_000_000e18 });
    }

    /// @dev Conditionally deploy V2 Periphery normally or from a source precompiled with via IR.
    function deployProtocolConditionally() internal {
        // We deploy from precompiled source if the Foundry profile is "test-optimized".
        if (isTestOptimizedProfile()) {
            plugin =
                SablierV2ProxyPlugin(deployCode("optimized-out/SablierV2ProxyPlugin.sol/SablierV2ProxyPlugin.json"));
            target = ISablierV2ProxyTarget(
                deployCode(
                    "optimized-out/SablierV2ProxyTarget.sol/SablierV2ProxyTarget.json", abi.encode(address(permit2))
                )
            );
        }
        // We deploy normally for all other profiles.
        else {
            plugin = new DeployProxyPlugin().run();
            target = new DeployProxyTarget().run(permit2);
        }
    }

    /// @dev Checks if the Foundry profile is "test-optimized".
    function isTestOptimizedProfile() internal returns (bool result) {
        string memory profile = vm.envOr("FOUNDRY_PROFILE", string(""));
        result = eqString(profile, "test-optimized");
    }

    /// @dev Labels the most relevant contracts.
    function labelContracts() internal {
        vm.label({ account: address(defaults), newLabel: "Defaults" });
        vm.label({ account: address(dynamic), newLabel: "LockupDynamic" });
        vm.label({ account: address(linear), newLabel: "LockupLinear" });
        vm.label({ account: address(permit2), newLabel: "Permit2" });
        vm.label({ account: address(proxy), newLabel: "Proxy" });
        vm.label({ account: address(target), newLabel: "Proxy Target" });
        vm.label({ account: address(usdc), newLabel: "USDC" });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    CALL EXPECTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Expects a call to {ISablierV2Lockup.cancel}.
    function expectCallToCancel(address lockup, uint256 streamId) internal {
        vm.expectCall({ callee: lockup, data: abi.encodeCall(ISablierV2Lockup.cancel, (streamId)) });
    }

    /// @dev Expects a call to {ISablierV2Lockup.cancelMultiple}.
    function expectCallToCancelMultiple(address lockup, uint256[] memory streamIds) internal {
        vm.expectCall({ callee: lockup, data: abi.encodeCall(ISablierV2Lockup.cancelMultiple, (streamIds)) });
    }

    /// @dev Expects a call to {ISablierV2LockupDynamic.createWithDeltas}.
    function expectCallToCreateWithDeltas(LockupDynamic.CreateWithDeltas memory params) internal {
        vm.expectCall({
            callee: address(dynamic),
            data: abi.encodeCall(ISablierV2LockupDynamic.createWithDeltas, (params))
        });
    }

    /// @dev Expects a call to {ISablierV2LockupLinear.createWithDurations}.
    function expectCallToCreateWithDurations(LockupLinear.CreateWithDurations memory params) internal {
        vm.expectCall({
            callee: address(linear),
            data: abi.encodeCall(ISablierV2LockupLinear.createWithDurations, (params))
        });
    }

    /// @dev Expects a call to {ISablierV2LockupDynamic.createWithMilestones}.
    function expectCallToCreateWithMilestones(LockupDynamic.CreateWithMilestones memory params) internal {
        vm.expectCall({
            callee: address(dynamic),
            data: abi.encodeCall(ISablierV2LockupDynamic.createWithMilestones, (params))
        });
    }

    /// @dev Expects a call to {ISablierV2LockupLinear.createWithRange}.
    function expectCallToCreateWithRange(LockupLinear.CreateWithRange memory params) internal {
        vm.expectCall({ callee: address(linear), data: abi.encodeCall(ISablierV2LockupLinear.createWithRange, (params)) });
    }

    /// @dev Expects a call to {IERC20.transfer}.
    function expectCallToTransfer(address to, uint256 amount) internal {
        vm.expectCall({ callee: address(usdc), data: abi.encodeCall(IERC20.transfer, (to, amount)) });
    }

    /// @dev Expects a call to {IERC20.transferFrom}.
    function expectCallToTransferFrom(address from, address to, uint256 amount) internal {
        vm.expectCall({ callee: address(usdc), data: abi.encodeCall(IERC20.transferFrom, (from, to, amount)) });
    }

    /// @dev Expects a call to {IERC20.transferFrom}.
    function expectCallToTransferFrom(address asset, address from, address to, uint256 amount) internal {
        vm.expectCall({ callee: asset, data: abi.encodeCall(IERC20.transferFrom, (from, to, amount)) });
    }

    /// @dev Expects multiple calls to {ISablierV2LockupDynamic.createWithMilestones}.
    function expectMultipleCallsToCreateWithDeltas(
        uint64 count,
        LockupDynamic.CreateWithDeltas memory params
    )
        internal
    {
        vm.expectCall({
            callee: address(dynamic),
            count: uint64(count),
            data: abi.encodeCall(ISablierV2LockupDynamic.createWithDeltas, (params))
        });
    }

    /// @dev Expects multiple calls to {ISablierV2LockupLinear.createWithDurations}.
    function expectMultipleCallsToCreateWithDurations(
        uint64 count,
        LockupLinear.CreateWithDurations memory params
    )
        internal
    {
        vm.expectCall({
            callee: address(linear),
            count: uint64(count),
            data: abi.encodeCall(ISablierV2LockupLinear.createWithDurations, (params))
        });
    }

    /// @dev Expects multiple calls to {ISablierV2LockupDynamic.createWithMilestones}.
    function expectMultipleCallsToCreateWithMilestones(
        uint64 count,
        LockupDynamic.CreateWithMilestones memory params
    )
        internal
    {
        vm.expectCall({
            callee: address(dynamic),
            count: uint64(count),
            data: abi.encodeCall(ISablierV2LockupDynamic.createWithMilestones, (params))
        });
    }

    /// @dev Expects multiple calls to {ISablierV2LockupLinear.createWithRange}.
    function expectMultipleCallsToCreateWithRange(uint64 count, LockupLinear.CreateWithRange memory params) internal {
        vm.expectCall({
            callee: address(linear),
            count: uint64(count),
            data: abi.encodeCall(ISablierV2LockupLinear.createWithRange, (params))
        });
    }

    /// @dev Expects multiple calls to {IERC20.transfer}.
    function expectMultipleCallsToTransfer(uint64 count, address to, uint256 amount) internal {
        vm.expectCall({
            callee: address(usdc),
            count: uint64(count),
            data: abi.encodeCall(IERC20.transfer, (to, amount))
        });
    }

    /// @dev Expects multiple calls to {IERC20.transferFrom}.
    function expectMultipleCallsToTransferFrom(uint64 count, address from, address to, uint256 amount) internal {
        vm.expectCall({
            callee: address(usdc),
            count: uint64(count),
            data: abi.encodeCall(IERC20.transferFrom, (from, to, amount))
        });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      PERMIT2
    //////////////////////////////////////////////////////////////////////////*/

    function getPermit2Signature(
        IAllowanceTransfer.PermitDetails memory details,
        uint256 privateKey,
        address spender
    )
        internal
        view
        returns (bytes memory sig)
    {
        bytes32 permitHash = keccak256(abi.encode(PermitHash._PERMIT_DETAILS_TYPEHASH, details));
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                permit2.DOMAIN_SEPARATOR(),
                keccak256(
                    abi.encode(PermitHash._PERMIT_SINGLE_TYPEHASH, permitHash, spender, defaults.PERMIT2_SIG_DEADLINE())
                )
            )
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);
        sig = bytes.concat(r, s, bytes1(v));
    }

    function permit2Params(uint160 amount) internal view returns (Permit2Params memory) {
        return Permit2Params({
            expiration: defaults.PERMIT2_EXPIRATION(),
            sigDeadline: defaults.PERMIT2_SIG_DEADLINE(),
            signature: getPermit2Signature({
                details: defaults.permitDetails(amount),
                privateKey: users.sender.key,
                spender: address(proxy)
            })
        });
    }

    function permit2Params(uint160 amount, uint48 nonce) internal view returns (Permit2Params memory) {
        return Permit2Params({
            expiration: defaults.PERMIT2_EXPIRATION(),
            sigDeadline: defaults.PERMIT2_SIG_DEADLINE(),
            signature: getPermit2Signature({
                details: defaults.permitDetails(amount, nonce),
                privateKey: users.sender.key,
                spender: address(proxy)
            })
        });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                       PLUGIN
    //////////////////////////////////////////////////////////////////////////*/

    function installPlugin() internal {
        bytes memory data = abi.encodeCall(proxyHelpers.installPlugin, (plugin));
        proxy.execute(address(proxyHelpers), data);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                       TARGET
    //////////////////////////////////////////////////////////////////////////*/

    function batchCreateWithDeltas() internal returns (uint256[] memory streamIds) {
        bytes memory data = abi.encodeCall(
            target.batchCreateWithDeltas,
            (dynamic, usdc, defaults.batchCreateWithDeltas(), permit2Params(defaults.TRANSFER_AMOUNT()))
        );
        bytes memory response = proxy.execute(address(target), data);
        streamIds = abi.decode(response, (uint256[]));
    }

    function batchCreateWithDurations() internal returns (uint256[] memory streamIds) {
        bytes memory data = abi.encodeCall(
            target.batchCreateWithDurations,
            (linear, usdc, defaults.batchCreateWithDurations(), permit2Params(defaults.TRANSFER_AMOUNT()))
        );
        bytes memory response = proxy.execute(address(target), data);
        streamIds = abi.decode(response, (uint256[]));
    }

    function batchCreateWithMilestones() internal returns (uint256[] memory streamIds) {
        bytes memory data = abi.encodeCall(
            target.batchCreateWithMilestones,
            (dynamic, usdc, defaults.batchCreateWithMilestones(), permit2Params(defaults.TRANSFER_AMOUNT()))
        );
        bytes memory response = proxy.execute(address(target), data);
        streamIds = abi.decode(response, (uint256[]));
    }

    function batchCreateWithMilestones(uint48 nonce) internal returns (uint256[] memory streamIds) {
        bytes memory data = abi.encodeCall(
            target.batchCreateWithMilestones,
            (dynamic, usdc, defaults.batchCreateWithMilestones(), permit2Params(defaults.TRANSFER_AMOUNT(), nonce))
        );
        bytes memory response = proxy.execute(address(target), data);
        streamIds = abi.decode(response, (uint256[]));
    }

    function batchCreateWithRange() internal returns (uint256[] memory streamIds) {
        bytes memory data = abi.encodeCall(
            target.batchCreateWithRange,
            (linear, usdc, defaults.batchCreateWithRange(), permit2Params(defaults.TRANSFER_AMOUNT()))
        );
        bytes memory response = proxy.execute(address(target), data);
        streamIds = abi.decode(response, (uint256[]));
    }

    function batchCreateWithRange(uint48 nonce) internal returns (uint256[] memory streamIds) {
        bytes memory data = abi.encodeCall(
            target.batchCreateWithRange,
            (linear, usdc, defaults.batchCreateWithRange(), permit2Params(defaults.TRANSFER_AMOUNT(), nonce))
        );
        bytes memory response = proxy.execute(address(target), data);
        streamIds = abi.decode(response, (uint256[]));
    }

    function createWithDeltas() internal returns (uint256 streamId) {
        bytes memory data = abi.encodeCall(
            target.createWithDeltas, (dynamic, defaults.createWithDeltas(), permit2Params(defaults.PER_STREAM_AMOUNT()))
        );
        bytes memory response = proxy.execute(address(target), data);
        streamId = abi.decode(response, (uint256));
    }

    function createWithDurations() internal returns (uint256 streamId) {
        bytes memory data = abi.encodeCall(
            target.createWithDurations,
            (linear, defaults.createWithDurations(), permit2Params(defaults.PER_STREAM_AMOUNT()))
        );
        bytes memory response = proxy.execute(address(target), data);
        streamId = abi.decode(response, (uint256));
    }

    function createWithMilestones() internal returns (uint256 streamId) {
        bytes memory data = abi.encodeCall(
            target.createWithMilestones,
            (dynamic, defaults.createWithMilestones(), permit2Params(defaults.PER_STREAM_AMOUNT()))
        );
        bytes memory response = proxy.execute(address(target), data);
        streamId = abi.decode(response, (uint256));
    }

    function createWithRange() internal returns (uint256 streamId) {
        bytes memory data = abi.encodeCall(
            target.createWithRange, (linear, defaults.createWithRange(), permit2Params(defaults.PER_STREAM_AMOUNT()))
        );
        bytes memory response = proxy.execute(address(target), data);
        streamId = abi.decode(response, (uint256));
    }

    function createWithRange(LockupLinear.CreateWithRange memory params) internal returns (uint256 streamId) {
        bytes memory data =
            abi.encodeCall(target.createWithRange, (linear, params, permit2Params(defaults.PER_STREAM_AMOUNT())));
        bytes memory response = proxy.execute(address(target), data);
        streamId = abi.decode(response, (uint256));
    }
}
