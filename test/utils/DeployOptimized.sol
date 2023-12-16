// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { StdCheats } from "forge-std/src/StdCheats.sol";

import { ISablierV2Batch } from "../../src/interfaces/ISablierV2Batch.sol";
import { ISablierV2MerkleStreamerFactory } from "../../src/interfaces/ISablierV2MerkleStreamerFactory.sol";

abstract contract DeployOptimized is StdCheats {
    /// @dev Deploys {SablierV2Batch} from an optimized source compiled with `--via-ir`.
    function deployOptimizedBatch() internal returns (ISablierV2Batch) {
        return ISablierV2Batch(deployCode("out-optimized/SablierV2Batch.sol/SablierV2Batch.json"));
    }

    /// @dev Deploys {SablierV2MerkleStreamerFactory} from an optimized source compiled with `--via-ir`.
    function deployOptimizedMerkleStreamerFactory() internal returns (ISablierV2MerkleStreamerFactory) {
        return ISablierV2MerkleStreamerFactory(
            deployCode("out-optimized/SablierV2MerkleStreamerFactory.sol/SablierV2MerkleStreamerFactory.json")
        );
    }

    /// @notice Deploys all V2 Periphery contracts from a optimized source in the following order:
    ///
    /// 1. {SablierV2Batch}
    /// 2. {SablierV2MerkleStreamerFactory}
    function deployOptimizedPeriphery() internal returns (ISablierV2Batch, ISablierV2MerkleStreamerFactory) {
        return (deployOptimizedBatch(), deployOptimizedMerkleStreamerFactory());
    }
}
