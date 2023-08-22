// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";
import { BaseScript } from "@sablier/v2-core-script/Base.s.sol";

import { ISablierV2AirstreamCampaignFactory } from "../src/interfaces/ISablierV2AirstreamCampaignFactory.sol";
import { ISablierV2AirstreamCampaignLL } from "../src/interfaces/ISablierV2AirstreamCampaignLL.sol";

contract CreateAirstreamCampaignLL is BaseScript {
    function run(
        ISablierV2AirstreamCampaignFactory campaignFactory,
        address initialAdmin,
        IERC20 asset,
        bytes32 merkleRoot,
        bool cancelable,
        uint40 expiration,
        ISablierV2LockupLinear lockupLinear,
        uint40 cliffDuration,
        uint40 totalDuration,
        string memory ipfsCID,
        uint256 campaignTotalAmount,
        uint256 recipientsCount
    )
        public
        broadcast
        returns (ISablierV2AirstreamCampaignLL campaignLL)
    {
        campaignLL = campaignFactory.createAirstreamCampaignLL(
            initialAdmin,
            asset,
            merkleRoot,
            cancelable,
            expiration,
            lockupLinear,
            LockupLinear.Durations({ cliff: cliffDuration, total: totalDuration }),
            ipfsCID,
            campaignTotalAmount,
            recipientsCount
        );
    }
}
