// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <0.9.0;

import { BaseScript } from "./Base.s.sol";

import { SablierV2MerkleStreamerFactory } from "../src/SablierV2MerkleStreamerFactory.sol";
import { SablierV2Batch } from "../src/SablierV2Batch.sol";

/// @notice Deploys all V2 Periphery contract in the following order:
///
/// 1. {SablierV2Batch}
/// 2. {SablierV2MerkleStreamerFactory}
contract DeployPeriphery is BaseScript {
    function run()
        public
        broadcast
        returns (SablierV2Batch batch, SablierV2MerkleStreamerFactory merkleStreamerFactory)
    {
        batch = new SablierV2Batch();
        merkleStreamerFactory = new SablierV2MerkleStreamerFactory();
    }
}
