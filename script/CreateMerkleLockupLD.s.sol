// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { ISablierV2LockupDynamic } from "@sablier/v2-core/src/interfaces/ISablierV2LockupDynamic.sol";

import { BaseScript } from "./Base.s.sol";

import { ISablierV2MerkleLockupFactory } from "../src/interfaces/ISablierV2MerkleLockupFactory.sol";
import { ISablierV2MerkleLockupLD } from "../src/interfaces/ISablierV2MerkleLockupLD.sol";
import { MerkleLockup } from "../src/types/DataTypes.sol";

contract CreateMerkleLockupLD is BaseScript {
    struct Params {
        MerkleLockup.ConstructorParams baseParams;
        ISablierV2LockupDynamic lockupDynamic;
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
        returns (ISablierV2MerkleLockupLD merkleLockupLD)
    {
        merkleLockupLD = merkleLockupFactory.createMerkleLockupLD(
            params.baseParams, params.lockupDynamic, params.ipfsCID, params.campaignTotalAmount, params.recipientsCount
        );
    }
}
