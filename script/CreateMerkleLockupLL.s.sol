// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { BaseScript } from "./Base.s.sol";

import { ISablierV2MerkleLockupFactory } from "../src/interfaces/ISablierV2MerkleLockupFactory.sol";
import { ISablierV2MerkleLockupLL } from "../src/interfaces/ISablierV2MerkleLockupLL.sol";
import { MerkleLockup } from "../src/types/DataTypes.sol";

contract CreateMerkleLockupLL is BaseScript {
    struct Params {
        MerkleLockup.ConstructorParams constructorParams;
        ISablierV2LockupLinear lockupLinear;
        LockupLinear.Durations streamDurations;
        string ipfsCID;
        uint256 campaignTotalAmount;
        uint256 recipientsCount;
    }

    function run(
        ISablierV2MerkleLockupFactory merkleLockupFactory,
        Params calldata params
    )
        public
        broadcast
        returns (ISablierV2MerkleLockupLL merkleLockupLL)
    {
        merkleLockupLL = merkleLockupFactory.createMerkleLockupLL(
            params.constructorParams,
            params.lockupLinear,
            params.streamDurations,
            params.ipfsCID,
            params.campaignTotalAmount,
            params.recipientsCount
        );
    }
}
