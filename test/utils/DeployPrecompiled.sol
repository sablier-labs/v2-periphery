// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IAllowanceTransfer } from "@uniswap/permit2/interfaces/IAllowanceTransfer.sol";
import { StdCheats } from "forge-std/StdCheats.sol";

import { ISablierV2Archive } from "../../src/interfaces/ISablierV2Archive.sol";
import { ISablierV2Batch } from "../../src/interfaces/ISablierV2Batch.sol";
import { ISablierV2MerkleStreamerFactory } from "../../src/interfaces/ISablierV2MerkleStreamerFactory.sol";
import { ISablierV2ProxyPlugin } from "../../src/interfaces/ISablierV2ProxyPlugin.sol";
import { ISablierV2ProxyTarget } from "../../src/interfaces/ISablierV2ProxyTarget.sol";
import { SablierV2ProxyTargetApprove } from "../../src/SablierV2ProxyTargetApprove.sol";
import { SablierV2ProxyTargetPermit2 } from "../../src/SablierV2ProxyTargetPermit2.sol";
import { SablierV2ProxyTargetPush } from "../../src/SablierV2ProxyTargetPush.sol";

contract DeployPrecompiled is StdCheats {
    /// @dev Deploys {SablierV2Archive} from a source precompiled with `--via-ir`.
    function deployPrecompiledArchive(address initialAdmin) internal returns (ISablierV2Archive) {
        return ISablierV2Archive(
            deployCode("out-optimized/SablierV2Archive.sol/SablierV2Archive.json", abi.encode(initialAdmin))
        );
    }

    /// @dev Deploys {SablierV2Batch} from a source precompiled with `--via-ir`.
    function deployPrecompiledBatch() internal returns (ISablierV2Batch) {
        return ISablierV2Batch(deployCode("out-optimized/SablierV2Batch.sol/SablierV2Batch.json"));
    }

    /// @dev Deploys {SablierV2MerkleStreamerFactory} from a source precompiled with `--via-ir`.
    function deployPrecompiledMerkleStreamerFactory() internal returns (ISablierV2MerkleStreamerFactory) {
        return ISablierV2MerkleStreamerFactory(
            deployCode("out-optimized/SablierV2MerkleStreamerFactory.sol/SablierV2MerkleStreamerFactory.json")
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

    /// @dev Deploys {deployPrecompiledProxyTargetPush} from a source precompiled with `--via-ir`.
    function deployPrecompiledProxyTargetPush() internal returns (SablierV2ProxyTargetPush) {
        return SablierV2ProxyTargetPush(
            deployCode("out-optimized/SablierV2ProxyTargetPush.sol/SablierV2ProxyTargetPush.json")
        );
    }

    /// @notice Deploys all V2 Periphery contracts from a source precompiled with `--via-ir` in the following order:
    ///
    /// 1. {SablierV2Archive}
    /// 2. {SablierV2Batch}
    /// 3. {SablierV2MerkleStreamerFactory}
    /// 4. {SablierV2ProxyPlugin}
    /// 5. {SablierV2ProxyTargetApprove}
    /// 6. {SablierV2ProxyTargetPermit2}
    /// 7. {SablierV2ProxyTargetPush}
    function deployPrecompiledPeriphery(
        address initialAdmin_,
        IAllowanceTransfer permit2_
    )
        internal
        returns (
            ISablierV2Archive,
            ISablierV2Batch,
            ISablierV2MerkleStreamerFactory,
            ISablierV2ProxyPlugin,
            ISablierV2ProxyTarget,
            ISablierV2ProxyTarget,
            ISablierV2ProxyTarget
        )
    {
        ISablierV2Archive archive_ = deployPrecompiledArchive(initialAdmin_);
        return (
            archive_,
            deployPrecompiledBatch(),
            deployPrecompiledMerkleStreamerFactory(),
            deployPrecompiledProxyPlugin(archive_),
            deployPrecompiledProxyTargetApprove(),
            deployPrecompiledProxyTargetPermit2(permit2_),
            deployPrecompiledProxyTargetPush()
        );
    }
}
