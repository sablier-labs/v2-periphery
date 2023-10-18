// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IAllowanceTransfer } from "@uniswap/permit2/interfaces/IAllowanceTransfer.sol";
import { StdCheats } from "forge-std/StdCheats.sol";

import { ISablierV2Batch } from "../../src/interfaces/ISablierV2Batch.sol";
import { ISablierV2MerkleStreamerFactory } from "../../src/interfaces/ISablierV2MerkleStreamerFactory.sol";
import { SablierV2ProxyTargetApprove } from "../../src/SablierV2ProxyTargetApprove.sol";
import { SablierV2ProxyTargetPermit2 } from "../../src/SablierV2ProxyTargetPermit2.sol";
import { SablierV2ProxyTargetPush } from "../../src/SablierV2ProxyTargetPush.sol";

abstract contract DeployOptimized is StdCheats {
    /// @dev Deploys {SablierV2Batch} from a optimized source compiled with `--via-ir`.
    function deployOptimizedBatch() internal returns (ISablierV2Batch) {
        return ISablierV2Batch(deployCode("out-optimized/SablierV2Batch.sol/SablierV2Batch.json"));
    }

    /// @dev Deploys {SablierV2MerkleStreamerFactory} from a optimized source compiled with `--via-ir`.
    function deployOptimizedMerkleStreamerFactory() internal returns (ISablierV2MerkleStreamerFactory) {
        return ISablierV2MerkleStreamerFactory(
            deployCode("out-optimized/SablierV2MerkleStreamerFactory.sol/SablierV2MerkleStreamerFactory.json")
        );
    }

    /// @dev Deploys {SablierV2ProxyTargetApprove} from a optimized source compiled with `--via-ir`.
    function deployOptimizedProxyTargetApprove() internal returns (SablierV2ProxyTargetApprove) {
        return SablierV2ProxyTargetApprove(
            deployCode("out-optimized/SablierV2ProxyTargetApprove.sol/SablierV2ProxyTargetApprove.json")
        );
    }

    /// @dev Deploys {SablierV2ProxyTargetPermit2} from a optimized source compiled with `--via-ir`.
    function deployOptimizedProxyTargetPermit2(IAllowanceTransfer permit2_)
        internal
        returns (SablierV2ProxyTargetPermit2)
    {
        return SablierV2ProxyTargetPermit2(
            deployCode(
                "out-optimized/SablierV2ProxyTargetPermit2.sol/SablierV2ProxyTargetPermit2.json", abi.encode(permit2_)
            )
        );
    }

    /// @dev Deploys {SablierV2ProxyTargetPush} from a optimized source compiled with `--via-ir`.
    function deployOptimizedProxyTargetPush() internal returns (SablierV2ProxyTargetPush) {
        return SablierV2ProxyTargetPush(
            deployCode("out-optimized/SablierV2ProxyTargetPush.sol/SablierV2ProxyTargetPush.json")
        );
    }

    /// @notice Deploys all V2 Periphery contracts from a optimized source in the following order:
    ///
    /// 1. {SablierV2Batch}
    /// 2. {SablierV2MerkleStreamerFactory}
    /// 3. {SablierV2ProxyTargetApprove}
    /// 4. {SablierV2ProxyTargetPermit2}
    /// 5. {SablierV2ProxyTargetPush}
    function deployOptimizedPeriphery(IAllowanceTransfer permit2_)
        internal
        returns (
            ISablierV2Batch,
            ISablierV2MerkleStreamerFactory,
            SablierV2ProxyTargetApprove,
            SablierV2ProxyTargetPermit2,
            SablierV2ProxyTargetPush
        )
    {
        return (
            deployOptimizedBatch(),
            deployOptimizedMerkleStreamerFactory(),
            deployOptimizedProxyTargetApprove(),
            deployOptimizedProxyTargetPermit2(permit2_),
            deployOptimizedProxyTargetPush()
        );
    }
}
