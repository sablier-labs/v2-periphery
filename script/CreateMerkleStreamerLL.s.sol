// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";
import { BaseScript } from "./Base.s.sol";

import { ISablierV2MerkleStreamerFactory } from "../src/interfaces/ISablierV2MerkleStreamerFactory.sol";
import { ISablierV2MerkleStreamerLL } from "../src/interfaces/ISablierV2MerkleStreamerLL.sol";

contract CreateMerkleStreamerLL is BaseScript {
    struct Params {
        address initialAdmin;
        ISablierV2LockupLinear lockupLinear;
        IERC20 asset;
        bytes32 merkleRoot;
        uint40 expiration;
        LockupLinear.Durations streamDurations;
        bool cancelable;
        bool transferable;
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
            params.initialAdmin,
            params.lockupLinear,
            params.asset,
            params.merkleRoot,
            params.expiration,
            params.streamDurations,
            params.cancelable,
            params.transferable,
            params.ipfsCID,
            params.campaignTotalAmount,
            params.recipientsCount
        );
    }
}
