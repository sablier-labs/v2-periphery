// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { BaseScript } from "./Base.s.sol";

import { ISablierV2MerkleStreamerFactory } from "../src/interfaces/ISablierV2MerkleStreamerFactory.sol";
import { ISablierV2MerkleStreamerLL } from "../src/interfaces/ISablierV2MerkleStreamerLL.sol";
import { MerkleStreamer } from "../src/types/DataTypes.sol";

contract CreateMerkleStreamerLL is BaseScript {
    struct Params {
        MerkleStreamer.ConstructorParams constructorParams;
        ISablierV2LockupLinear lockupLinear;
        LockupLinear.Durations streamDurations;
        string ipfsCID;
        uint256 campaignTotalAmount;
        uint256 recipientsCount;
    }

    function run(
        ISablierV2MerkleStreamerFactory merkleStreamerFactory,
        Params calldata params
    )
        public
        broadcast
        returns (ISablierV2MerkleStreamerLL merkleStreamerLL)
    {
        merkleStreamerLL = merkleStreamerFactory.createMerkleStreamerLL(
            params.constructorParams,
            params.lockupLinear,
            params.streamDurations,
            params.ipfsCID,
            params.campaignTotalAmount,
            params.recipientsCount
        );
    }
}
