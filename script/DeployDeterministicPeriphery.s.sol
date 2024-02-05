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
    function run(string memory create2Salt)
        public
        virtual
        broadcast
        returns (SablierV2Batch batch, SablierV2MerkleStreamerFactory merkleStreamerFactory)
    {
        bytes32 salt = _constructCreate2Salt();
        batch = new SablierV2Batch{ salt: salt }();
        merkleStreamerFactory = new SablierV2MerkleStreamerFactory{ salt: bytes32(abi.encodePacked(create2Salt)) }();
    }
}
