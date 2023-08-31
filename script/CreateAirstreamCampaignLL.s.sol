// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";
import { BaseScript } from "@sablier/v2-core-script/Base.s.sol";

import { ISablierV2AirstreamCampaignFactory } from "../src/interfaces/ISablierV2AirstreamCampaignFactory.sol";
import { ISablierV2AirstreamCampaignLL } from "../src/interfaces/ISablierV2AirstreamCampaignLL.sol";

contract CreateAirstreamCampaignLL is BaseScript {
    struct Params {
        address initialAdmin;
        ISablierV2LockupLinear lockupLinear;
        IERC20 asset;
        bytes32 merkleRoot;
        uint40 expiration;
        LockupLinear.Durations airstreamDurations;
        bool cancelable;
        string ipfsCID;
        uint256 campaignTotalAmount;
        uint256 recipientsCount;
    }

    function run(
        ISablierV2AirstreamCampaignFactory airstreamCampaignFactory,
        Params calldata params
    )
        public
        broadcast
        returns (ISablierV2AirstreamCampaignLL airstreamCampaignLL)
    {
        airstreamCampaignLL = airstreamCampaignFactory.createAirstreamCampaignLL(
            params.initialAdmin,
            params.lockupLinear,
            params.asset,
            params.merkleRoot,
            params.expiration,
            params.airstreamDurations,
            params.cancelable,
            params.ipfsCID,
            params.campaignTotalAmount,
            params.recipientsCount
        );
    }
}
