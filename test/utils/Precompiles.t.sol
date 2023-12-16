// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { LibString } from "solady/src/utils/LibString.sol";

import { ISablierV2Batch } from "../../src/interfaces/ISablierV2Batch.sol";
import { ISablierV2MerkleStreamerFactory } from "../../src/interfaces/ISablierV2MerkleStreamerFactory.sol";

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

    function test_DeployBatch() external onlyTestOptimizedProfile {
        address actualBatch = address(precompiles.deployBatch());
        address expectedBatch = address(deployOptimizedBatch());
        assertEq(actualBatch.code, expectedBatch.code, "bytecodes mismatch");
    }

    function test_DeployMerkleStreamerFactory() external onlyTestOptimizedProfile {
        address actualFactory = address(precompiles.deployMerkleStreamerFactory());
        address expectedFactory = address(deployOptimizedMerkleStreamerFactory());
        assertEq(actualFactory.code, expectedFactory.code, "bytecodes mismatch");
    }

    function test_DeployPeriphery() external onlyTestOptimizedProfile {
        (ISablierV2Batch actualBatch, ISablierV2MerkleStreamerFactory actualMerkleStreamerFactory) =
            precompiles.deployPeriphery();

        (ISablierV2Batch expectedBatch, ISablierV2MerkleStreamerFactory expectedMerkleStreamerFactory) =
            deployOptimizedPeriphery();

        assertEq(address(actualBatch).code, address(expectedBatch).code, "bytecodes mismatch");
        assertEq(
            address(actualMerkleStreamerFactory).code, address(expectedMerkleStreamerFactory).code, "bytecodes mismatch"
        );
    }
}
