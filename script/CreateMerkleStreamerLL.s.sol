// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { BaseScript } from "./Base.s.sol";

import { ISablierV2MerkleStreamerFactory } from "../src/interfaces/ISablierV2MerkleStreamerFactory.sol";
import { ISablierV2MerkleStreamerLL } from "../src/interfaces/ISablierV2MerkleStreamerLL.sol";
import { MerkleStreamerFactory } from "../src/types/DataTypes.sol";

contract CreateMerkleStreamerLL is BaseScript {
    function run(
        ISablierV2MerkleStreamerFactory merkleStreamerFactory,
        MerkleStreamerFactory.CreateLL memory params
    )
        public
        broadcast
        returns (ISablierV2MerkleStreamerLL merkleStreamerLL)
    {
        merkleStreamerLL = merkleStreamerFactory.createMerkleStreamerLL(params);
    }
}
