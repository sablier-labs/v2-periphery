// SPDX-License-Identifier: UNLICENSED
// solhint-disable max-states-count
pragma solidity >=0.8.19 <0.9.0;

<<<<<<< HEAD
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { IPRBProxy } from "@prb/proxy/src/interfaces/IPRBProxy.sol";
import { IPRBProxyRegistry } from "@prb/proxy/src/interfaces/IPRBProxyRegistry.sol";
import { ISablierV2Lockup } from "@sablier/v2-core/src/interfaces/ISablierV2Lockup.sol";
import { ISablierV2LockupDynamic } from "@sablier/v2-core/src/interfaces/ISablierV2LockupDynamic.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { LockupDynamic, LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";
import { IAllowanceTransfer } from "@uniswap/permit2/interfaces/IAllowanceTransfer.sol";

import { Utils as V2CoreUtils } from "@sablier/v2-core-test/utils/Utils.sol";
import { StdCheats } from "forge-std/StdCheats.sol";

import { ISablierV2Archive } from "src/interfaces/ISablierV2Archive.sol";
import { ISablierV2ProxyPlugin } from "src/interfaces/ISablierV2ProxyPlugin.sol";
import { ISablierV2ProxyTarget } from "src/interfaces/ISablierV2ProxyTarget.sol";
import { IWrappedNativeAsset } from "src/interfaces/IWrappedNativeAsset.sol";
import { SablierV2Archive } from "src/SablierV2Archive.sol";
import { SablierV2ProxyPlugin } from "src/SablierV2ProxyPlugin.sol";
import { SablierV2ProxyTargetApprove } from "src/SablierV2ProxyTargetApprove.sol";
import { SablierV2ProxyTargetPermit2 } from "src/SablierV2ProxyTargetPermit2.sol";
import { SablierV2ProxyTargetPush } from "src/SablierV2ProxyTargetPush.sol";

import { WLC } from "./mocks/WLC.sol";
import { Assertions } from "./utils/Assertions.sol";
import { Defaults } from "./utils/Defaults.sol";
import { Events } from "./utils/Events.sol";
import { Users } from "./utils/Types.sol";
=======
// solhint-disable no-unused-import
import "./BaseImports.t.sol";
>>>>>>> 8693746 (test: lockup linear campaign's functions)

/// @notice Base test contract with common logic needed by all tests.
abstract contract Base_Test is Assertions, Events, StdCheats, V2CoreUtils {
    /*//////////////////////////////////////////////////////////////////////////
                                     VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    Users internal users;

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    ISablierV2Archive internal archive;
    IPRBProxy internal aliceProxy;
    IERC20 internal asset;
    ISablierV2AirstreamCampaignLL internal campaignLL;
    ISablierV2AirstreamCampaignFactory internal campaignFactory;
    Defaults internal defaults;
    ISablierV2LockupDynamic internal lockupDynamic;
    ISablierV2LockupLinear internal lockupLinear;
    IAllowanceTransfer internal permit2;
    ISablierV2ProxyPlugin internal plugin;
    IPRBProxyRegistry internal proxyRegistry;
    ISablierV2ProxyTarget internal target;
    SablierV2ProxyTargetApprove internal targetApprove;
    SablierV2ProxyTargetPermit2 internal targetPermit2;
    SablierV2ProxyTargetPush internal targetPush;
    IWrappedNativeAsset internal weth;
    WLC internal wlc;

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual {
        // Deploy the default test asset.
        asset = new ERC20("DAI Stablecoin", "DAI");

        // Create users for testing.
        users.alice = createUser("Alice");
        users.admin = createUser("Admin");
        users.broker = createUser("Broker");
        users.eve = createUser("Eve");
        users.recipient = createUser("Recipient");
        users.recipient1 = createUser("Recipient1");
        users.recipient2 = createUser("Recipient2");
        users.recipient3 = createUser("Recipient3");
        users.recipient4 = createUser("Recipient4");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Generates a user, labels its address, and funds it with ETH.
    function createUser(string memory name) internal returns (Account memory user) {
        user = makeAccount(name);
        vm.deal({ account: user.addr, newBalance: 100_000 ether });
        deal({ token: address(asset), to: user.addr, give: 1_000_000e18 });
    }

    /// @dev Conditionally deploy V2 Periphery normally or from a source precompiled with `--via-ir`.
    function deployPeripheryConditionally() internal {
        if (!isTestOptimizedProfile()) {
            archive = new SablierV2Archive(users.admin.addr);
            campaignFactory = new SablierV2AirstreamCampaignFactory();
            plugin = new SablierV2ProxyPlugin(archive);
            targetApprove = new SablierV2ProxyTargetApprove();
            targetPermit2 = new SablierV2ProxyTargetPermit2(permit2);
            targetPush = new SablierV2ProxyTargetPush();
        } else {
            archive = deployPrecompiledArchive(users.admin.addr);
            campaignFactory = deployPrecompiledCampaignFactory();
            plugin = deployPrecompiledProxyPlugin(archive);
            targetApprove = deployPrecompiledProxyTargetApprove();
            targetPermit2 = deployPrecompiledProxyTargetPermit2(permit2);
            targetPush = deployPrecompiledProxyTargetPush();
        }
        // The default target.
        target = targetApprove;
    }

    /// @dev Deploys {SablierV2Archive} from a source precompiled with `--via-ir`.
    function deployPrecompiledArchive(address initialAdmin) internal returns (ISablierV2Archive) {
        return ISablierV2Archive(
            deployCode("out-optimized/SablierV2Archive.sol/SablierV2Archive.json", abi.encode(initialAdmin))
        );
    }

    /// @dev Deploys {SablierV2AirstreamCampaignFactory} from a source precompiled with `--via-ir`.
    function deployPrecompiledCampaignFactory() internal returns (ISablierV2AirstreamCampaignFactory) {
        return ISablierV2AirstreamCampaignFactory(
            deployCode("out-optimized/SablierV2AirstreamCampaignFactory.sol/SablierV2AirstreamCampaignFactory.json")
        );
    }

    /// @dev Deploys {SablierV2ProxyPlugin} from a source precompiled with `--via-ir`.
    function deployPrecompiledProxyPlugin(ISablierV2Archive archive_) internal returns (ISablierV2ProxyPlugin) {
        return ISablierV2ProxyPlugin(
            deployCode("out-optimized/SablierV2ProxyPlugin.sol/SablierV2ProxyPlugin.json", abi.encode(archive_))
        );
    }

    /// @dev Deploys {SablierV2ProxyTargetApprove} from a source precompiled with `--via-ir`.
    function deployPrecompiledProxyTargetApprove() internal returns (SablierV2ProxyTargetApprove) {
        return SablierV2ProxyTargetApprove(
            deployCode("out-optimized/SablierV2ProxyTargetApprove.sol/SablierV2ProxyTargetApprove.json")
        );
    }

    /// @dev Deploys {SablierV2ProxyTargetPermit2} from a source precompiled with `--via-ir`.
    function deployPrecompiledProxyTargetPermit2(IAllowanceTransfer permit2_)
        internal
        returns (SablierV2ProxyTargetPermit2)
    {
        return SablierV2ProxyTargetPermit2(
            deployCode(
                "out-optimized/SablierV2ProxyTargetPermit2.sol/SablierV2ProxyTargetPermit2.json", abi.encode(permit2_)
            )
        );
    }

    /// @dev Deploys {deployPrecompiledProxyTargetPush} from a source precompiled with `--via-ir`.
    function deployPrecompiledProxyTargetPush() internal returns (SablierV2ProxyTargetPush) {
        return SablierV2ProxyTargetPush(
            deployCode("out-optimized/SablierV2ProxyTargetPush.sol/SablierV2ProxyTargetPush.json")
        );
    }

    /// @dev Labels the most relevant contracts.
    function labelContracts() internal {
        vm.label({ account: address(aliceProxy), newLabel: "Alice's Proxy" });
        vm.label({ account: address(archive), newLabel: "Archive" });
        vm.label({ account: address(asset), newLabel: IERC20Metadata(address(asset)).symbol() });
        vm.label({ account: address(campaignFactory), newLabel: "CampaignFactory" });
        vm.label({ account: address(campaignLL), newLabel: "Campaign LL" });
        vm.label({ account: address(defaults), newLabel: "Defaults" });
        vm.label({ account: address(lockupDynamic), newLabel: "LockupDynamic" });
        vm.label({ account: address(lockupLinear), newLabel: "LockupLinear" });
        vm.label({ account: address(permit2), newLabel: "Permit2" });
        vm.label({ account: address(plugin), newLabel: "ProxyPlugin" });
        vm.label({ account: address(targetApprove), newLabel: "ProxyTargetApprove" });
        vm.label({ account: address(targetPermit2), newLabel: "ProxyTargetPermit2" });
        vm.label({ account: address(targetPush), newLabel: "ProxyTargetPush" });
        vm.label({ account: address(wlc), newLabel: "WLC" });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    CALL EXPECTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Expects a call to {ISablierV2Lockup.cancel}.
    function expectCallToCancel(ISablierV2Lockup lockup, uint256 streamId) internal {
        vm.expectCall({ callee: address(lockup), data: abi.encodeCall(ISablierV2Lockup.cancel, (streamId)) });
    }

    /// @dev Expect calls to {ISablierV2Lockup.cancel}, {IERC20.transfer}, and {IERC20.transferFrom}.
    function expectCallsToCancelAndTransfer(
        ISablierV2Lockup cancelContract,
        ISablierV2Lockup createContract,
        uint256 streamId
    )
        internal
    {
        expectCallToCancel(cancelContract, streamId);

        // Asset flow: Sablier → proxy → proxy owner
        // Expect transfers from Sablier to the proxy, and then from the proxy to the proxy owner.
        expectCallToTransfer({ to: address(aliceProxy), amount: defaults.PER_STREAM_AMOUNT() });
        expectCallToTransfer({ to: users.alice.addr, amount: defaults.PER_STREAM_AMOUNT() });

        // Asset flow: proxy owner → proxy → Sablier
        // Expect transfers from the proxy owner to the proxy, and then from the proxy to the Sablier contract.
        expectCallToTransferFrom({
            from: users.alice.addr,
            to: address(aliceProxy),
            amount: defaults.PER_STREAM_AMOUNT()
        });
        expectCallToTransferFrom({
            from: address(aliceProxy),
            to: address(createContract),
            amount: defaults.PER_STREAM_AMOUNT()
        });
    }

    /// @dev Expects a call to {ISablierV2Lockup.cancelMultiple}.
    function expectCallToCancelMultiple(ISablierV2Lockup lockup, uint256[] memory streamIds) internal {
        vm.expectCall({ callee: address(lockup), data: abi.encodeCall(ISablierV2Lockup.cancelMultiple, (streamIds)) });
    }

    /// @dev Expects a call to {ISablierV2LockupDynamic.createWithDeltas}.
    function expectCallToCreateWithDeltas(LockupDynamic.CreateWithDeltas memory params) internal {
        vm.expectCall({
            callee: address(lockupDynamic),
            data: abi.encodeCall(ISablierV2LockupDynamic.createWithDeltas, (params))
        });
    }

    /// @dev Expects a call to {ISablierV2LockupLinear.createWithDurations}.
    function expectCallToCreateWithDurations(LockupLinear.CreateWithDurations memory params) internal {
        vm.expectCall({
            callee: address(lockupLinear),
            data: abi.encodeCall(ISablierV2LockupLinear.createWithDurations, (params))
        });
    }

    /// @dev Expects a call to {ISablierV2LockupDynamic.createWithMilestones}.
    function expectCallToCreateWithMilestones(LockupDynamic.CreateWithMilestones memory params) internal {
        vm.expectCall({
            callee: address(lockupDynamic),
            data: abi.encodeCall(ISablierV2LockupDynamic.createWithMilestones, (params))
        });
    }

    /// @dev Expects a call to {ISablierV2LockupLinear.createWithRange}.
    function expectCallToCreateWithRange(LockupLinear.CreateWithRange memory params) internal {
        vm.expectCall({
            callee: address(lockupLinear),
            data: abi.encodeCall(ISablierV2LockupLinear.createWithRange, (params))
        });
    }

    /// @dev Expects a call to {IERC20.transfer}.
    function expectCallToTransfer(address to, uint256 amount) internal {
        expectCallToTransfer(address(asset), to, amount);
    }

    /// @dev Expects a call to {IERC20.transfer}.
    function expectCallToTransfer(address asset_, address to, uint256 amount) internal {
        if (target != targetPush) {
            vm.expectCall({ callee: asset_, data: abi.encodeCall(IERC20.transfer, (to, amount)) });
        }
    }

    /// @dev Expects a call to {IERC20.transferFrom}.
    function expectCallToTransferFrom(address from, address to, uint256 amount) internal {
        expectCallToTransferFrom(address(asset), from, to, amount);
    }

    /// @dev Expects a call to {IERC20.transferFrom}.
    function expectCallToTransferFrom(address asset_, address from, address to, uint256 amount) internal {
        if (target != targetPush) {
            vm.expectCall({ callee: asset_, data: abi.encodeCall(IERC20.transferFrom, (from, to, amount)) });
        }
    }

    /// @dev Expects multiple calls to {ISablierV2LockupDynamic.createWithDeltas}, each with the specified
    /// `params`.
    function expectMultipleCallsToCreateWithDeltas(
        uint64 count,
        LockupDynamic.CreateWithDeltas memory params
    )
        internal
    {
        vm.expectCall({
            callee: address(lockupDynamic),
            count: count,
            data: abi.encodeCall(ISablierV2LockupDynamic.createWithDeltas, (params))
        });
    }

    /// @dev Expects multiple calls to {ISablierV2LockupDynamic.createWithDurations}, each with the specified
    /// `params`.
    function expectMultipleCallsToCreateWithDurations(
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

    /// @dev Expects multiple calls to {ISablierV2LockupDynamic.createWithMilestones}, each with the specified
    /// `params`.
    function expectMultipleCallsToCreateWithMilestones(
        uint64 count,
        LockupDynamic.CreateWithMilestones memory params
    )
        internal
    {
        vm.expectCall({
            callee: address(lockupDynamic),
            count: count,
            data: abi.encodeCall(ISablierV2LockupDynamic.createWithMilestones, (params))
        });
    }

    /// @dev Expects multiple calls to {ISablierV2LockupDynamic.createWithRange}, each with the specified
    /// `params`.
    function expectMultipleCallsToCreateWithRange(uint64 count, LockupLinear.CreateWithRange memory params) internal {
        vm.expectCall({
            callee: address(lockupLinear),
            count: count,
            data: abi.encodeCall(ISablierV2LockupLinear.createWithRange, (params))
        });
    }

    /// @dev Expects multiple calls to {IERC20.transfer}.
    function expectMultipleCallsToTransfer(uint64 count, address to, uint256 amount) internal {
        vm.expectCall({ callee: address(asset), count: count, data: abi.encodeCall(IERC20.transfer, (to, amount)) });
    }

    /// @dev Expects multiple calls to {IERC20.transferFrom}.
    function expectMultipleCallsToTransferFrom(uint64 count, address from, address to, uint256 amount) internal {
        expectMultipleCallsToTransferFrom(address(asset), count, from, to, amount);
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
                                 AIRSTREAM-CAMPAIGN
    //////////////////////////////////////////////////////////////////////////*/

    function claimLL() internal returns (uint256) {
        return campaignLL.claim({
            index: defaults.INDEX1(),
            recipient: users.recipient1.addr,
            amount: defaults.CLAIMABLE_AMOUNT(),
            merkleProof: defaults.index1Proof()
        });
    }

    function createAirstreamCampaignLL() internal {
        campaignLL = createAirstreamCampaignLL(users.admin.addr);
    }

    function createAirstreamCampaignLL(address admin) internal returns (ISablierV2AirstreamCampaignLL) {
        return campaignFactory.createAirstreamCampaignLL({
            initialAdmin: admin,
            asset: asset,
            merkleRoot: defaults.merkleRoot(),
            cancelable: defaults.CANCELABLE(),
            expiration: defaults.EXPIRATION(),
            lockupLinear: lockupLinear,
            durations: defaults.durations(),
            ipfsCID: defaults.IPFS_CID(),
            campaignTotalAmount: defaults.CAMPAIGN_TOTAL_AMOUNT(),
            recipientsCount: defaults.RECIPIENTS_COUNT()
        });
    }

    function computeCampaignLLAddress() internal returns (address) {
        return computeCampaignLLAddress(users.admin.addr, defaults.merkleRoot());
    }

    function computeCampaignLLAddress(address admin) internal returns (address) {
        return computeCampaignLLAddress(admin, defaults.merkleRoot());
    }

    function computeCampaignLLAddress(address admin, bytes32 merkleRoot) internal returns (address) {
        bytes32 salt = keccak256(abi.encodePacked(admin, asset, merkleRoot, defaults.EXPIRATION()));
        bytes32 creationBytecodeHash = keccak256(getCampaignLLBytecode(admin, merkleRoot));
        return computeCreate2Address({
            salt: salt,
            initcodeHash: creationBytecodeHash,
            deployer: address(campaignFactory)
        });
    }

    function getCampaignLLBytecode(address admin, bytes32 merkleRoot) internal returns (bytes memory) {
        bytes memory constructorArgs = abi.encode(
            admin, asset, merkleRoot, defaults.CANCELABLE(), defaults.EXPIRATION(), lockupLinear, defaults.durations()
        );
        if (!isTestOptimizedProfile()) {
            return bytes.concat(type(SablierV2AirstreamCampaignLL).creationCode, constructorArgs);
        } else {
            return bytes.concat(
                vm.getCode("out-optimized/SablierV2AirstreamCampaignLL.sol/PRBProxy.json"), constructorArgs
            );
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                                       TARGET
    //////////////////////////////////////////////////////////////////////////*/

    function batchCreateWithDeltas() internal returns (uint256[] memory) {
        bytes memory data = abi.encodeCall(
            target.batchCreateWithDeltas,
            (lockupDynamic, asset, defaults.batchCreateWithDeltas(), getTransferData(defaults.TOTAL_TRANSFER_AMOUNT()))
        );
        bytes memory response = aliceProxy.execute(address(target), data);
        return abi.decode(response, (uint256[]));
    }

    function batchCreateWithDurations() internal returns (uint256[] memory) {
        bytes memory data = abi.encodeCall(
            target.batchCreateWithDurations,
            (
                lockupLinear,
                asset,
                defaults.batchCreateWithDurations(),
                getTransferData(defaults.TOTAL_TRANSFER_AMOUNT())
            )
        );
        bytes memory response = aliceProxy.execute(address(target), data);
        return abi.decode(response, (uint256[]));
    }

    function batchCreateWithMilestones() internal returns (uint256[] memory) {
        bytes memory data = abi.encodeCall(
            target.batchCreateWithMilestones,
            (
                lockupDynamic,
                asset,
                defaults.batchCreateWithMilestones(),
                getTransferData(defaults.TOTAL_TRANSFER_AMOUNT())
            )
        );
        bytes memory response = aliceProxy.execute(address(target), data);
        return abi.decode(response, (uint256[]));
    }

    function batchCreateWithMilestones(uint256 batchSize) internal returns (uint256[] memory) {
        uint128 totalTransferAmount = uint128(batchSize) * defaults.PER_STREAM_AMOUNT();
        bytes memory data = abi.encodeCall(
            target.batchCreateWithMilestones,
            (lockupDynamic, asset, defaults.batchCreateWithMilestones(batchSize), getTransferData(totalTransferAmount))
        );
        bytes memory response = aliceProxy.execute(address(target), data);
        return abi.decode(response, (uint256[]));
    }

    function batchCreateWithRange() internal returns (uint256[] memory) {
        bytes memory data = abi.encodeCall(
            target.batchCreateWithRange,
            (lockupLinear, asset, defaults.batchCreateWithRange(), getTransferData(defaults.TOTAL_TRANSFER_AMOUNT()))
        );
        bytes memory response = aliceProxy.execute(address(target), data);
        return abi.decode(response, (uint256[]));
    }

    function batchCreateWithRange(uint256 batchSize) internal returns (uint256[] memory) {
        uint128 totalTransferAmount = uint128(batchSize) * defaults.PER_STREAM_AMOUNT();
        bytes memory data = abi.encodeCall(
            target.batchCreateWithRange,
            (lockupLinear, asset, defaults.batchCreateWithRange(batchSize), getTransferData(totalTransferAmount))
        );
        bytes memory response = aliceProxy.execute(address(target), data);
        return abi.decode(response, (uint256[]));
    }

    function createWithDeltas() internal returns (uint256) {
        bytes memory data = abi.encodeCall(
            target.createWithDeltas,
            (lockupDynamic, defaults.createWithDeltas(), getTransferData(defaults.PER_STREAM_AMOUNT()))
        );
        bytes memory response = aliceProxy.execute(address(target), data);
        return abi.decode(response, (uint256));
    }

    function createWithDurations() internal returns (uint256) {
        bytes memory data = abi.encodeCall(
            target.createWithDurations,
            (lockupLinear, defaults.createWithDurations(), getTransferData(defaults.PER_STREAM_AMOUNT()))
        );
        bytes memory response = aliceProxy.execute(address(target), data);
        return abi.decode(response, (uint256));
    }

    function createWithMilestones() internal returns (uint256) {
        bytes memory data = abi.encodeCall(
            target.createWithMilestones,
            (lockupDynamic, defaults.createWithMilestones(), getTransferData(defaults.PER_STREAM_AMOUNT()))
        );
        bytes memory response = aliceProxy.execute(address(target), data);
        return abi.decode(response, (uint256));
    }

    function createWithMilestones(LockupDynamic.CreateWithMilestones memory params) internal returns (uint256) {
        bytes memory data = abi.encodeCall(
            target.createWithMilestones, (lockupDynamic, params, getTransferData(defaults.PER_STREAM_AMOUNT()))
        );
        bytes memory response = aliceProxy.execute(address(target), data);
        return abi.decode(response, (uint256));
    }

    function createWithRange() internal returns (uint256) {
        bytes memory data = abi.encodeCall(
            target.createWithRange,
            (lockupLinear, defaults.createWithRange(), getTransferData(defaults.PER_STREAM_AMOUNT()))
        );
        bytes memory response = aliceProxy.execute(address(target), data);
        return abi.decode(response, (uint256));
    }

    function createWithRange(LockupLinear.CreateWithRange memory params) internal returns (uint256) {
        bytes memory data = abi.encodeCall(
            target.createWithRange, (lockupLinear, params, getTransferData(defaults.PER_STREAM_AMOUNT()))
        );
        bytes memory response = aliceProxy.execute(address(target), data);
        return abi.decode(response, (uint256));
    }

    function getTransferData(uint160 amount) internal view returns (bytes memory) {
        if (target == targetPermit2) {
            return defaults.permit2Params(amount);
        }
        // The {ProxyTargetApprove} contract does not require any transfer data.
        return bytes("");
    }
}
