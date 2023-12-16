// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <0.9.0;

import { BaseScript } from "./Base.s.sol";

import { SablierV2MerkleStreamerFactory } from "../src/SablierV2MerkleStreamerFactory.sol";

contract DeployMerkleStreamerFactory is BaseScript {
    function run() public broadcast returns (SablierV2MerkleStreamerFactory merkleStreamerFactory) {
        merkleStreamerFactory = new SablierV2MerkleStreamerFactory();
    }
}
