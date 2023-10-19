// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <0.9.0;

import { BaseScript } from "@sablier/v2-core-script/Base.s.sol";
import { IAllowanceTransfer } from "@uniswap/permit2/interfaces/IAllowanceTransfer.sol";

import { SablierV2Batch } from "../src/SablierV2Batch.sol";
import { SablierV2MerkleStreamerFactory } from "../src/SablierV2MerkleStreamerFactory.sol";
import { SablierV2ProxyTargetApprove } from "../src/SablierV2ProxyTargetApprove.sol";
import { SablierV2ProxyTargetPermit2 } from "../src/SablierV2ProxyTargetPermit2.sol";
import { SablierV2ProxyTargetPush } from "../src/SablierV2ProxyTargetPush.sol";

/// @notice Deploys all V2 Periphery contracts at deterministic addresses across chains, in the following order:
///
/// 1. {SablierV2Batch}
/// 2. {SablierV2MerkleStreamerFactory}
/// 3. {SablierV2ProxyTargetApprove}
/// 4. {SablierV2ProxyTargetPermit2}
/// 5. {SablierV2ProxyTargetPush}
///
/// @dev Reverts if any contract has already been deployed.
contract DeployDeterministicPeriphery is BaseScript {
    struct DeployedContracts {
        SablierV2Batch batch;
        SablierV2MerkleStreamerFactory merkleStreamerFactory;
        SablierV2ProxyTargetApprove targetApprove;
        SablierV2ProxyTargetPermit2 targetPermit2;
        SablierV2ProxyTargetPush targetPush;
    }

    /// @dev The presence of the salt instructs Forge to deploy the contract via a deterministic CREATE2 factory.
    /// https://github.com/Arachnid/deterministic-deployment-proxy
    function run(
        string memory create2Salt,
        IAllowanceTransfer permit2
    )
        public
        virtual
        broadcast
        returns (DeployedContracts memory deployedContracts)
    {
        deployedContracts.batch = new SablierV2Batch{ salt: bytes32(abi.encodePacked(create2Salt)) }();
        deployedContracts.merkleStreamerFactory =
            new SablierV2MerkleStreamerFactory{ salt: bytes32(abi.encodePacked(create2Salt)) }();
        deployedContracts.targetApprove =
            new SablierV2ProxyTargetApprove{ salt: bytes32(abi.encodePacked(create2Salt)) }();
        deployedContracts.targetPermit2 =
            new SablierV2ProxyTargetPermit2{ salt: bytes32(abi.encodePacked(create2Salt)) }(permit2);
        deployedContracts.targetPush = new SablierV2ProxyTargetPush{ salt: bytes32(abi.encodePacked(create2Salt)) }();
    }
}
