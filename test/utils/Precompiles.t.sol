// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Precompiles } from "../../precompiles/Precompiles.sol";
import { ISablierV2Batch } from "../../src/interfaces/ISablierV2Batch.sol";
import { ISablierV2MerkleLockupFactory } from "../../src/interfaces/ISablierV2MerkleLockupFactory.sol";

import { Base_Test } from "../Base.t.sol";

contract Precompiles_Test is Base_Test {
    Precompiles internal precompiles = new Precompiles();

    modifier onlyTestOptimizedProfile() {
        if (isTestOptimizedProfile()) {
            _;
        }
    }

    function test_DeployBatch() external onlyTestOptimizedProfile {
        address actualBatch = address(precompiles.deployBatch());
        address expectedBatch = address(deployOptimizedBatch());
        assertEq(actualBatch.code, expectedBatch.code, "bytecodes mismatch");
    }

    function test_DeployMerkleLockupFactory() external onlyTestOptimizedProfile {
        address actualFactory = address(precompiles.deployMerkleLockupFactory());
        address expectedFactory = address(deployOptimizedMerkleLockupFactory());
        assertEq(actualFactory.code, expectedFactory.code, "bytecodes mismatch");
    }

    function test_DeployPeriphery() external onlyTestOptimizedProfile {
        (ISablierV2Batch actualBatch, ISablierV2MerkleLockupFactory actualMerkleLockupFactory) =
            precompiles.deployPeriphery();

        (ISablierV2Batch expectedBatch, ISablierV2MerkleLockupFactory expectedMerkleLockupFactory) =
            deployOptimizedPeriphery();

        assertEq(address(actualBatch).code, address(expectedBatch).code, "bytecodes mismatch");
        assertEq(
            address(actualMerkleLockupFactory).code, address(expectedMerkleLockupFactory).code, "bytecodes mismatch"
        );
    }
}
