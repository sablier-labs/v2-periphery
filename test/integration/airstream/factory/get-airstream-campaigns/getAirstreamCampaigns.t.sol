// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ISablierV2AirstreamCampaign } from "src/interfaces/ISablierV2AirstreamCampaign.sol";

import { Integration_Test } from "../../../Integration.t.sol";

contract GetAirstreamCampaigns_Integration_Test is Integration_Test {
    function test_GetAirstreamCampaigns_Empty() external {
        ISablierV2AirstreamCampaign[] memory campaigns = campaignFactory.getAirstreamCampaigns(users.admin.addr);
        assertTrue(campaigns.length == 0, "campaigns arrays not empty");
    }

    function test_GetAirstreamCampaigns_CampaignLD() external {
        address expectedCampaignLD = address(createAirstreamCampaignLD());
        ISablierV2AirstreamCampaign[] memory campaigns = campaignFactory.getAirstreamCampaigns(users.admin.addr);
        address actualCampaignLD = address(campaigns[0]);
        assertEq(actualCampaignLD, expectedCampaignLD, "getAirstreamCampaigns LD");
    }

    function test_GetAirstreamCampaigns_CampaignLL() external {
        address expectedCampaignLL = address(createAirstreamCampaignLL());
        ISablierV2AirstreamCampaign[] memory campaigns = campaignFactory.getAirstreamCampaigns(users.admin.addr);
        address actualCampaignLL = address(campaigns[0]);
        assertEq(actualCampaignLL, expectedCampaignLL, "getAirstreamCampaigns LL");
    }

    function test_GetAirstreamCampaigns_Campaigns_LD_LL() external {
        address expectedCampaignLD = address(createAirstreamCampaignLD());
        address expectedCampaignLL = address(createAirstreamCampaignLL());
        ISablierV2AirstreamCampaign[] memory campaigns = campaignFactory.getAirstreamCampaigns(users.admin.addr);
        address actualCampaignLD = address(campaigns[0]);
        address actualCampaignLL = address(campaigns[1]);
        assertEq(actualCampaignLD, expectedCampaignLD, "getAirstreamCampaigns LD");
        assertEq(actualCampaignLL, expectedCampaignLL, "getAirstreamCampaigns LL");
    }
}
