// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { StdCheats } from "forge-std/src/StdCheats.sol";

import { ISablierV2Batch } from "../../src/interfaces/ISablierV2Batch.sol";
import { ISablierV2MerkleLockupFactory } from "../../src/interfaces/ISablierV2MerkleLockupFactory.sol";

abstract contract DeployOptimized is StdCheats {
    /// @dev Deploys {SablierV2Batch} from an optimized source compiled with `--via-ir`.
    function deployOptimizedBatch() internal returns (ISablierV2Batch) {
        return ISablierV2Batch(deployCode("out-optimized/SablierV2Batch.sol/SablierV2Batch.json"));
    }

    /// @dev Deploys {SablierV2MerkleLockupFactory} from an optimized source compiled with `--via-ir`.
    function deployOptimizedMerkleLockupFactory() internal returns (ISablierV2MerkleLockupFactory) {
        return ISablierV2MerkleLockupFactory(
            deployCode("out-optimized/SablierV2MerkleLockupFactory.sol/SablierV2MerkleLockupFactory.json")
        );
    }

    /// @notice Deploys all V2 Periphery contracts from a optimized source in the following order:
    ///
    /// 1. {SablierV2Batch}
    /// 2. {SablierV2MerkleLockupFactory}
    function deployOptimizedPeriphery() internal returns (ISablierV2Batch, ISablierV2MerkleLockupFactory) {
        return (deployOptimizedBatch(), deployOptimizedMerkleLockupFactory());
    }
}
