// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { ISablierV2LockupTranched } from "@sablier/v2-core/src/interfaces/ISablierV2LockupTranched.sol";

import { BaseScript } from "./Base.s.sol";

import { ISablierV2MerkleLockupFactory } from "../src/interfaces/ISablierV2MerkleLockupFactory.sol";
import { ISablierV2MerkleLT } from "../src/interfaces/ISablierV2MerkleLT.sol";
import { MerkleLockup, MerkleLT } from "../src/types/DataTypes.sol";

contract CreateMerkleLT is BaseScript {
    struct Params {
        MerkleLockup.ConstructorParams baseParams;
        ISablierV2LockupTranched lockupTranched;
        MerkleLT.TrancheWithPercentage[] tranchesWithPercentages;
        uint256 campaignTotalAmount;
        uint256 recipientCount;
    }

    /// @dev Deploy via Forge.
    function run(
        ISablierV2MerkleLockupFactory merkleLockupFactory,
        Params calldata params
    )
        public
        virtual
        broadcast
        returns (ISablierV2MerkleLT merkleLT)
    {
        merkleLT = merkleLockupFactory.createMerkleLT(
            params.baseParams,
            params.lockupTranched,
            params.tranchesWithPercentages,
            params.campaignTotalAmount,
            params.recipientCount
        );
    }
}
