// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <0.9.0;

import { BaseScript } from "./Base.s.sol";

import { SablierV2Batch } from "../src/SablierV2Batch.sol";
import { SablierV2MerkleStreamerFactory } from "../src/SablierV2MerkleStreamerFactory.sol";

/// @notice Deploys all V2 Periphery contracts at deterministic addresses across chains, in the following order:
///
/// 1. {SablierV2Batch}
/// 2. {SablierV2MerkleStreamerFactory}
///
/// @dev Reverts if any contract has already been deployed.
contract DeployDeterministicPeriphery is BaseScript {
    /// @dev The presence of the salt instructs Forge to deploy the contract via a deterministic CREATE2 factory.
    /// https://github.com/Arachnid/deterministic-deployment-proxy
    function run(string memory create2Salt)
        public
        virtual
        broadcast
        returns (SablierV2Batch batch, SablierV2MerkleStreamerFactory merkleStreamerFactory)
    {
        batch = new SablierV2Batch{ salt: bytes32(abi.encodePacked(create2Salt)) }();
        merkleStreamerFactory = new SablierV2MerkleStreamerFactory{ salt: bytes32(abi.encodePacked(create2Salt)) }();
    }
}
