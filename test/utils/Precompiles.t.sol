// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { IAllowanceTransfer } from "@uniswap/permit2/interfaces/IAllowanceTransfer.sol";
import { DeployPermit2 } from "@uniswap/permit2-test/utils/DeployPermit2.sol";
import { LibString } from "solady/utils/LibString.sol";

import { ISablierV2MerkleStreamerFactory } from "../../src/interfaces/ISablierV2MerkleStreamerFactory.sol";
import { ISablierV2Archive } from "../../src/interfaces/ISablierV2Archive.sol";
import { ISablierV2Batch } from "../../src/interfaces/ISablierV2Batch.sol";
import { ISablierV2ProxyPlugin } from "../../src/interfaces/ISablierV2ProxyPlugin.sol";
import { ISablierV2ProxyTarget } from "../../src/interfaces/ISablierV2ProxyTarget.sol";

import { Base_Test } from "../Base.t.sol";
import { Precompiles } from "./Precompiles.sol";

contract Precompiles_Test is Base_Test {
    using LibString for address;
    using LibString for string;

    Precompiles internal precompiles = new Precompiles();

    modifier onlyTestOptimizedProfile() {
        if (isTestOptimizedProfile()) {
            _;
        }
    }

    function test_DeployMerkleStreamerFactory() external onlyTestOptimizedProfile {
        address actualFactory = address(precompiles.deployMerkleStreamerFactory());
        address expectedFactory = address(deployPrecompiledMerkleStreamerFactory());
        assertEq(actualFactory.code, expectedFactory.code, "bytecodes mismatch");
    }

    function test_DeployArchive() external onlyTestOptimizedProfile {
        address actualArchive = address(precompiles.deployArchive(users.admin.addr));
        address expectedArchive = address(deployPrecompiledArchive(users.admin.addr));
        assertEq(actualArchive.code, expectedArchive.code, "bytecodes mismatch");
    }

    function test_DeployBatch() external onlyTestOptimizedProfile {
        address actualBatch = address(precompiles.deployBatch());
        address expectedBatch = address(deployPrecompiledBatch());
        assertEq(actualBatch.code, expectedBatch.code, "bytecodes mismatch");
    }

    function test_DeployProxyPlugin() external onlyTestOptimizedProfile {
        ISablierV2Archive archive = deployPrecompiledArchive(users.admin.addr);
        address actualProxyPlugin = address(precompiles.deployProxyPlugin(archive));
        address expectedProxyPlugin = address(deployPrecompiledProxyPlugin(archive));
        bytes memory expectedProxyPluginCode =
            adjustBytecode(expectedProxyPlugin.code, expectedProxyPlugin, actualProxyPlugin);
        assertEq(actualProxyPlugin.code, expectedProxyPluginCode, "bytecodes mismatch");
    }

    function test_DeployProxyTargetApprove() external onlyTestOptimizedProfile {
        address actualProxyTargetApprove = address(precompiles.deployProxyTargetApprove());
        address expectedProxyTargetApprove = address(deployPrecompiledProxyTargetApprove());
        bytes memory expectedProxyTargetCode =
            adjustBytecode(expectedProxyTargetApprove.code, expectedProxyTargetApprove, actualProxyTargetApprove);
        assertEq(actualProxyTargetApprove.code, expectedProxyTargetCode, "bytecodes mismatch");
    }

    function test_DeployProxyTargetPermit2() external onlyTestOptimizedProfile {
        IAllowanceTransfer permit2 = IAllowanceTransfer(new DeployPermit2().run());
        address actualProxyTargetPermit2 = address(precompiles.deployProxyTargetPermit2(permit2));
        address expectedProxyTargetPermit2 = address(deployPrecompiledProxyTargetPermit2(permit2));
        bytes memory expectedProxyTargetCode =
            adjustBytecode(expectedProxyTargetPermit2.code, expectedProxyTargetPermit2, actualProxyTargetPermit2);
        assertEq(actualProxyTargetPermit2.code, expectedProxyTargetCode, "bytecodes mismatch");
    }

    function test_DeployProxyTargetPush() external onlyTestOptimizedProfile {
        address actualProxyTargetPush = address(precompiles.deployProxyTargetPush());
        address expectedProxyTargetPush = address(deployPrecompiledProxyTargetPush());
        bytes memory expectedProxyTargetCode =
            adjustBytecode(expectedProxyTargetPush.code, expectedProxyTargetPush, actualProxyTargetPush);
        assertEq(actualProxyTargetPush.code, expectedProxyTargetCode, "bytecodes mismatch");
    }

    /// @dev Needed to prevent "Stack too deep" error
    struct Vars {
        IAllowanceTransfer permit2;
        ISablierV2MerkleStreamerFactory actualMerkleStreamerFactory;
        ISablierV2Archive actualArchive;
        ISablierV2Batch actualBatch;
        ISablierV2ProxyPlugin actualProxyPlugin;
        ISablierV2ProxyTarget actualProxyTargetApprove;
        ISablierV2ProxyTarget actualProxyTargetPermit2;
        ISablierV2ProxyTarget actualProxyTargetPush;
        address expectedArchive;
        address expectedBatch;
        address expectedMerkleStreamerFactory;
        address expectedProxyPlugin;
        address expectedProxyTargetApprove;
        address expectedProxyTargetPermit2;
        address expectedProxyTargetPush;
    }

    function test_DeployPeriphery() external onlyTestOptimizedProfile {
        Vars memory vars;

        vars.permit2 = IAllowanceTransfer(new DeployPermit2().run());
        (
            vars.actualMerkleStreamerFactory,
            vars.actualArchive,
            vars.actualBatch,
            vars.actualProxyPlugin,
            vars.actualProxyTargetApprove,
            vars.actualProxyTargetPermit2,
            vars.actualProxyTargetPush
        ) = precompiles.deployPeriphery(users.admin.addr, permit2);

        vars.expectedMerkleStreamerFactory = address(deployPrecompiledMerkleStreamerFactory());
        assertEq(
            address(vars.actualMerkleStreamerFactory).code,
            address(vars.expectedMerkleStreamerFactory).code,
            "bytecodes mismatch"
        );

        vars.expectedArchive = address(deployPrecompiledArchive(users.admin.addr));
        assertEq(address(vars.actualArchive).code, vars.expectedArchive.code, "bytecodes mismatch");

        vars.expectedBatch = address(deployPrecompiledBatch());
        assertEq(address(vars.actualBatch).code, vars.expectedBatch.code, "bytecodes mismatch");

        vars.expectedProxyPlugin = address(deployPrecompiledProxyPlugin(vars.actualArchive));
        bytes memory expectedLockupDynamicCode =
            adjustBytecode(vars.expectedProxyPlugin.code, vars.expectedProxyPlugin, address(vars.actualProxyPlugin));
        assertEq(address(vars.actualProxyPlugin).code, expectedLockupDynamicCode, "bytecodes mismatch");

        vars.expectedProxyTargetApprove = address(deployPrecompiledProxyTargetApprove());
        bytes memory expectedProxyTargetApproveCode = adjustBytecode(
            vars.expectedProxyTargetApprove.code,
            vars.expectedProxyTargetApprove,
            address(vars.actualProxyTargetApprove)
        );
        assertEq(address(vars.actualProxyTargetApprove).code, expectedProxyTargetApproveCode, "bytecodes mismatch");

        vars.expectedProxyTargetPermit2 = address(deployPrecompiledProxyTargetPermit2(permit2));
        bytes memory expectedProxyTargetPermit2Code = adjustBytecode(
            vars.expectedProxyTargetPermit2.code,
            vars.expectedProxyTargetPermit2,
            address(vars.actualProxyTargetPermit2)
        );
        assertEq(address(vars.actualProxyTargetPermit2).code, expectedProxyTargetPermit2Code, "bytecodes mismatch");

        vars.expectedProxyTargetPush = address(deployPrecompiledProxyTargetPush());
        bytes memory expectedProxyTargetPushCode = adjustBytecode(
            vars.expectedProxyTargetPush.code, vars.expectedProxyTargetPush, address(vars.actualProxyTargetPush)
        );
        assertEq(address(vars.actualProxyTargetPush).code, expectedProxyTargetPushCode, "bytecodes mismatch");
    }

    /// @dev The expected bytecode has to be adjusted because some contracts inherit from {OnlyDelegateCall}, which
    /// saves the contract's own address in storage.
    function adjustBytecode(
        bytes memory bytecode,
        address expectedAddress,
        address actualAddress
    )
        internal
        pure
        returns (bytes memory)
    {
        return vm.parseBytes(
            vm.toString(bytecode).replace({
                search: expectedAddress.toHexStringNoPrefix(),
                replacement: actualAddress.toHexStringNoPrefix()
            })
        );
    }
}
