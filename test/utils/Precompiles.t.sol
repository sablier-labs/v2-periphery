// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { IAllowanceTransfer } from "@uniswap/permit2/interfaces/IAllowanceTransfer.sol";
import { DeployPermit2 } from "@uniswap/permit2-test/utils/DeployPermit2.sol";
import { LibString } from "solady/utils/LibString.sol";

import { ISablierV2Archive } from "../../src/interfaces/ISablierV2Archive.sol";
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

    function test_DeployPeriphery() external onlyTestOptimizedProfile {
        IAllowanceTransfer permit2 = IAllowanceTransfer(new DeployPermit2().run());
        (
            ISablierV2Archive actualArchive,
            ISablierV2ProxyPlugin actualProxyPlugin,
            ISablierV2ProxyTarget actualProxyTargetApprove,
            ISablierV2ProxyTarget actualProxyTargetPermit2,
            ISablierV2ProxyTarget actualProxyTargetPush
        ) = precompiles.deployPeriphery(users.admin.addr, permit2);

        address expectedArchive = address(deployPrecompiledArchive(users.admin.addr));
        assertEq(address(actualArchive).code, expectedArchive.code, "bytecodes mismatch");

        address expectedProxyPlugin = address(deployPrecompiledProxyPlugin(actualArchive));
        bytes memory expectedLockupDynamicCode =
            adjustBytecode(expectedProxyPlugin.code, expectedProxyPlugin, address(actualProxyPlugin));
        assertEq(address(actualProxyPlugin).code, expectedLockupDynamicCode, "bytecodes mismatch");

        address expectedProxyTargetApprove = address(deployPrecompiledProxyTargetApprove());
        bytes memory expectedProxyTargetApproveCode = adjustBytecode(
            expectedProxyTargetApprove.code, expectedProxyTargetApprove, address(actualProxyTargetApprove)
        );
        assertEq(address(actualProxyTargetApprove).code, expectedProxyTargetApproveCode, "bytecodes mismatch");

        address expectedProxyTargetPermit2 = address(deployPrecompiledProxyTargetPermit2(permit2));
        bytes memory expectedProxyTargetPermit2Code = adjustBytecode(
            expectedProxyTargetPermit2.code, expectedProxyTargetPermit2, address(actualProxyTargetPermit2)
        );
        assertEq(address(actualProxyTargetPermit2).code, expectedProxyTargetPermit2Code, "bytecodes mismatch");

        address expectedProxyTargetPush = address(deployPrecompiledProxyTargetPush());
        bytes memory expectedProxyTargetPushCode =
            adjustBytecode(expectedProxyTargetPush.code, expectedProxyTargetPush, address(actualProxyTargetPush));
        assertEq(address(actualProxyTargetPush).code, expectedProxyTargetPushCode, "bytecodes mismatch");
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
