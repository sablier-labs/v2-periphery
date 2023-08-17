// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

// solhint-disable no-unused-import
import "./BaseImports.t.sol";

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
    ISablierV2AirstreamCampaign internal campaign;
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
        } else {
            archive = deployPrecompiledArchive(users.admin.addr);
            campaignFactory = deployPrecompiledCampaignFactory();
            plugin = deployPrecompiledProxyPlugin(archive);
            targetApprove = deployPrecompiledProxyTargetApprove();
            targetPermit2 = deployPrecompiledProxyTargetPermit2(permit2);
        }
        // The ERC-20 target is the default target.
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

    /// @dev Labels the most relevant contracts.
    function labelContracts() internal {
        vm.label({ account: address(aliceProxy), newLabel: "Alice's Proxy" });
        vm.label({ account: address(archive), newLabel: "Archive" });
        vm.label({ account: address(asset), newLabel: IERC20Metadata(address(asset)).symbol() });
        vm.label({ account: address(defaults), newLabel: "Defaults" });
        vm.label({ account: address(lockupDynamic), newLabel: "LockupDynamic" });
        vm.label({ account: address(lockupLinear), newLabel: "LockupLinear" });
        vm.label({ account: address(permit2), newLabel: "Permit2" });
        vm.label({ account: address(plugin), newLabel: "ProxyPlugin" });
        vm.label({ account: address(targetApprove), newLabel: "ProxyTargetApprove" });
        vm.label({ account: address(targetPermit2), newLabel: "ProxyTargetPermit2" });
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
        vm.expectCall({ callee: asset_, data: abi.encodeCall(IERC20.transfer, (to, amount)) });
    }

    /// @dev Expects a call to {IERC20.transferFrom}.
    function expectCallToTransferFrom(address from, address to, uint256 amount) internal {
        expectCallToTransferFrom(address(asset), from, to, amount);
    }

    /// @dev Expects a call to {IERC20.transferFrom}.
    function expectCallToTransferFrom(address asset_, address from, address to, uint256 amount) internal {
        vm.expectCall({ callee: asset_, data: abi.encodeCall(IERC20.transferFrom, (from, to, amount)) });
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

    function claim() internal returns (uint256) {
        return campaign.claim(
            defaults.INDEX1(), users.recipient1.addr, defaults.CLAIMABLE_AMOUNT(), defaults.index1Proof()
        );
    }

    function createAirstreamCampaignLD() internal returns (ISablierV2AirstreamCampaignLD) {
        return campaignFactory.createAirstreamCampaignLD(
            users.admin.addr,
            asset,
            defaults.merkleRoot(),
            defaults.CANCELABLE(),
            defaults.EXPIRATION(),
            lockupDynamic,
            defaults.segmentsWithDeltas(),
            defaults.IPFS_CID(),
            defaults.CAMPAIGN_TOTAL_AMOUNT(),
            defaults.RECIPIENTS_COUNT()
        );
    }

    function computeCampaignLDAddress() internal returns (address) {
        bytes32 salt = keccak256(
            abi.encodePacked(
                users.admin.addr, asset, defaults.merkleRoot(), defaults.CANCELABLE(), defaults.EXPIRATION()
            )
        );
        bytes32 creationBytecodeHash = keccak256(getCampaignLDBytecode());
        return computeCreate2Address({
            salt: salt,
            initcodeHash: creationBytecodeHash,
            deployer: address(campaignFactory)
        });
    }

    function getCampaignLDBytecode() internal returns (bytes memory) {
        bytes memory constructorArgs = abi.encode(
            users.admin.addr,
            asset,
            defaults.merkleRoot(),
            defaults.CANCELABLE(),
            defaults.EXPIRATION(),
            lockupDynamic,
            defaults.segmentsWithDeltas()
        );
        if (!isTestOptimizedProfile()) {
            return bytes.concat(type(SablierV2AirstreamCampaignLD).creationCode, constructorArgs);
        } else {
            return bytes.concat(
                vm.getCode("out-optimized/SablierV2AirstreamCampaignLD.sol/SablierV2AirstreamCampaignLD.json"),
                constructorArgs
            );
        }
    }

    function createAirstreamCampaignLL() internal returns (ISablierV2AirstreamCampaignLL) {
        return campaignFactory.createAirstreamCampaignLL(
            users.admin.addr,
            asset,
            defaults.merkleRoot(),
            defaults.CANCELABLE(),
            defaults.EXPIRATION(),
            lockupLinear,
            defaults.durations(),
            defaults.IPFS_CID(),
            defaults.CAMPAIGN_TOTAL_AMOUNT(),
            defaults.RECIPIENTS_COUNT()
        );
    }

    function computeCampaignLLAddress() internal returns (address) {
        bytes32 salt = keccak256(
            abi.encodePacked(
                users.admin.addr, asset, defaults.merkleRoot(), defaults.CANCELABLE(), defaults.EXPIRATION()
            )
        );
        bytes32 creationBytecodeHash = keccak256(getCampaignLLBytecode());
        // Use the Create2 utility from Forge Std.
        return computeCreate2Address({
            salt: salt,
            initcodeHash: creationBytecodeHash,
            deployer: address(campaignFactory)
        });
    }

    function getCampaignLLBytecode() internal returns (bytes memory) {
        bytes memory constructorArgs = abi.encode(
            users.admin.addr,
            asset,
            defaults.merkleRoot(),
            defaults.CANCELABLE(),
            defaults.EXPIRATION(),
            lockupLinear,
            defaults.durations()
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
