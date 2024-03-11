// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { ISablierV2LockupTranched } from "@sablier/v2-core/src/interfaces/ISablierV2LockupTranched.sol";

import { BaseScript } from "./Base.s.sol";

import { ISablierV2MerkleLockupFactory } from "../src/interfaces/ISablierV2MerkleLockupFactory.sol";
import { ISablierV2MerkleLockupLT } from "../src/interfaces/ISablierV2MerkleLockupLT.sol";
import { MerkleLockup, MerkleLockupLT } from "../src/types/DataTypes.sol";

contract CreateMerkleLockupLT is BaseScript {
    struct Params {
        MerkleLockup.ConstructorParams baseParams;
        ISablierV2LockupTranched lockupTranched;
        MerkleLockupLT.TrancheWithPercentage[] tranchesWithPercentages;
        uint256 campaignTotalAmount;
        uint256 recipientsCount;
    }

    function run(
        ISablierV2MerkleLockupFactory merkleLockupFactory,
        Params calldata params
    )
        public
        broadcast
        returns (ISablierV2MerkleLockupLT merkleLockupLT)
    {
        merkleLockupLT = merkleLockupFactory.createMerkleLockupLT(
            params.baseParams,
            params.lockupTranched,
            params.tranchesWithPercentages,
            params.campaignTotalAmount,
            params.recipientsCount
        );
    }
}
