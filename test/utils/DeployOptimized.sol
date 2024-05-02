// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { StdCheats } from "forge-std/src/StdCheats.sol";

import { ISablierV2BatchLockup } from "../../src/interfaces/ISablierV2BatchLockup.sol";
import { ISablierV2MerkleLockupFactory } from "../../src/interfaces/ISablierV2MerkleLockupFactory.sol";

abstract contract DeployOptimized is StdCheats {
    /// @dev Deploys {SablierV2BatchLockup} from an optimized source compiled with `--via-ir`.
    function deployOptimizedBatchLockup(address initialAdmin) internal returns (ISablierV2BatchLockup) {
        return ISablierV2BatchLockup(
            deployCode("out-optimized/SablierV2BatchLockup.sol/SablierV2BatchLockup.json", abi.encode(initialAdmin))
        );
    }

    /// @dev Deploys {SablierV2MerkleLockupFactory} from an optimized source compiled with `--via-ir`.
    function deployOptimizedMerkleLockupFactory(address initialAdmin)
        internal
        returns (ISablierV2MerkleLockupFactory)
    {
        return ISablierV2MerkleLockupFactory(
            deployCode(
                "out-optimized/SablierV2MerkleLockupFactory.sol/SablierV2MerkleLockupFactory.json",
                abi.encode(initialAdmin)
            )
        );
    }

    /// @notice Deploys all V2 Periphery contracts from an optimized source in the following order:
    ///
    /// 1. {SablierV2BatchLockup}
    /// 2. {SablierV2MerkleLockupFactory}
    function deployOptimizedPeriphery(address initialAdmin)
        internal
        returns (ISablierV2BatchLockup, ISablierV2MerkleLockupFactory)
    {
        return (deployOptimizedBatchLockup(initialAdmin), deployOptimizedMerkleLockupFactory(initialAdmin));
    }
}
