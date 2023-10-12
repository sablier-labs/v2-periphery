// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IAllowanceTransfer } from "@uniswap/permit2/interfaces/IAllowanceTransfer.sol";
import { DeployPermit2 } from "@uniswap/permit2-test/utils/DeployPermit2.sol";
import { LibString } from "solady/utils/LibString.sol";

import { ISablierV2Archive } from "../../src/interfaces/ISablierV2Archive.sol";
import { ISablierV2Batch } from "../../src/interfaces/ISablierV2Batch.sol";
import { ISablierV2MerkleStreamerFactory } from "../../src/interfaces/ISablierV2MerkleStreamerFactory.sol";
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

    function test_DeployMerkleStreamerFactory() external onlyTestOptimizedProfile {
        address actualFactory = address(precompiles.deployMerkleStreamerFactory());
        address expectedFactory = address(deployPrecompiledMerkleStreamerFactory());
        assertEq(actualFactory.code, expectedFactory.code, "bytecodes mismatch");
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
        ISablierV2Archive actualArchive;
        ISablierV2Batch actualBatch;
        ISablierV2MerkleStreamerFactory actualMerkleStreamerFactory;
        ISablierV2ProxyPlugin actualProxyPlugin;
        ISablierV2ProxyTarget actualProxyTargetApprove;
        ISablierV2ProxyTarget actualProxyTargetPermit2;
        ISablierV2ProxyTarget actualProxyTargetPush;
        ISablierV2Archive expectedArchive;
        ISablierV2Batch expectedBatch;
        ISablierV2MerkleStreamerFactory expectedMerkleStreamerFactory;
        ISablierV2ProxyPlugin expectedProxyPlugin;
        bytes expectedProxyPluginCode;
        ISablierV2ProxyTarget expectedProxyTargetApprove;
        bytes expectedProxyTargetApproveCode;
        ISablierV2ProxyTarget expectedProxyTargetPermit2;
        bytes expectedProxyTargetPermit2Code;
        ISablierV2ProxyTarget expectedProxyTargetPush;
        bytes expectedProxyTargetPushCode;
    }

    function test_DeployPeriphery() external onlyTestOptimizedProfile {
        Vars memory vars;

        vars.permit2 = IAllowanceTransfer(new DeployPermit2().run());
        (
            vars.actualArchive,
            vars.actualBatch,
            vars.actualMerkleStreamerFactory,
            vars.actualProxyPlugin,
            vars.actualProxyTargetApprove,
            vars.actualProxyTargetPermit2,
            vars.actualProxyTargetPush
        ) = precompiles.deployPeriphery(users.admin.addr, permit2);

        (
            vars.expectedArchive,
            vars.expectedBatch,
            vars.expectedMerkleStreamerFactory,
            vars.expectedProxyPlugin,
            vars.expectedProxyTargetApprove,
            vars.expectedProxyTargetPermit2,
            vars.expectedProxyTargetPush
        ) = deployPrecompiledPeriphery(users.admin.addr, permit2);

        assertEq(address(vars.actualArchive).code, address(vars.expectedArchive).code, "bytecodes mismatch");
        assertEq(address(vars.actualBatch).code, address(vars.expectedBatch).code, "bytecodes mismatch");
        assertEq(
            address(vars.actualMerkleStreamerFactory).code,
            address(vars.expectedMerkleStreamerFactory).code,
            "bytecodes mismatch"
        );

        // We need to deploy the Proxy Plugin again here because the address of the Archive passed inside the
        // `deployPrecompiledPeriphery` function is `vars.expectedProxyPlugin`. Otherwise we cannot adjust the
        // bytecode correctly.
        vars.expectedProxyPlugin = deployPrecompiledProxyPlugin(vars.actualArchive);
        vars.expectedProxyPluginCode = adjustBytecode(
            address(vars.expectedProxyPlugin).code, address(vars.expectedProxyPlugin), address(vars.actualProxyPlugin)
        );
        vars.expectedProxyTargetApproveCode = adjustBytecode(
            address(vars.expectedProxyTargetApprove).code,
            address(vars.expectedProxyTargetApprove),
            address(vars.actualProxyTargetApprove)
        );

        vars.expectedProxyTargetPermit2Code = adjustBytecode(
            address(vars.expectedProxyTargetPermit2).code,
            address(vars.expectedProxyTargetPermit2),
            address(vars.actualProxyTargetPermit2)
        );

        vars.expectedProxyTargetPushCode = adjustBytecode(
            address(vars.expectedProxyTargetPush).code,
            address(vars.expectedProxyTargetPush),
            address(vars.actualProxyTargetPush)
        );

        assertEq(address(vars.actualProxyPlugin).code, vars.expectedProxyPluginCode, "bytecodes mismatch");
        assertEq(address(vars.actualProxyTargetApprove).code, vars.expectedProxyTargetApproveCode, "bytecodes mismatch");
        assertEq(address(vars.actualProxyTargetPermit2).code, vars.expectedProxyTargetPermit2Code, "bytecodes mismatch");
        assertEq(address(vars.actualProxyTargetPush).code, vars.expectedProxyTargetPushCode, "bytecodes mismatch");
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
