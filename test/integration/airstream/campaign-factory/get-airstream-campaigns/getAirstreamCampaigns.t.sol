// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ISablierV2AirstreamCampaign } from "src/interfaces/ISablierV2AirstreamCampaign.sol";

import { Integration_Test } from "../../../Integration.t.sol";

contract GetAirstreamCampaigns_Integration_Test is Integration_Test {
    function setUp() public override {
        Integration_Test.setUp();
    }

    function test_GetAirstreamCampaigns_Empty(address admin) external {
        vm.assume(admin != users.admin.addr);
        ISablierV2AirstreamCampaign[] memory campaigns = campaignFactory.getAirstreamCampaigns(admin);
        assertTrue(campaigns.length == 0, "campaigns arrays not empty");
    }

    function test_GetAirstreamCampaigns_CampaignLD() external {
        ISablierV2AirstreamCampaign[] memory campaigns = campaignFactory.getAirstreamCampaigns(users.admin.addr);
        address actualCampaignLD = address(campaigns[0]); // `campaignLD` is the first campaign created
        address expectedCampaignLD = address(campaignLD);
        assertEq(actualCampaignLD, expectedCampaignLD, "getAirstreamCampaigns LD");
    }

    function test_GetAirstreamCampaigns_CampaignLL() external {
        ISablierV2AirstreamCampaign[] memory campaigns = campaignFactory.getAirstreamCampaigns(users.admin.addr);
        address actualCampaignLL = address(campaigns[1]); // `campaignLL` is the second campaign created
        address expectedCampaignLL = address(campaignLL);
        assertEq(actualCampaignLL, expectedCampaignLL, "getAirstreamCampaigns LL");
    }

    function test_GetAirstreamCampaigns_Campaigns_LD_LL() external {
        ISablierV2AirstreamCampaign[] memory campaigns = campaignFactory.getAirstreamCampaigns(users.admin.addr);
        address actualCampaignLD = address(campaigns[0]);
        address actualCampaignLL = address(campaigns[1]);
        address expectedCampaignLD = address(campaignLD);
        address expectedCampaignLL = address(campaignLL);
        assertEq(actualCampaignLD, expectedCampaignLD, "getAirstreamCampaigns LD");
        assertEq(actualCampaignLL, expectedCampaignLL, "getAirstreamCampaigns LL");
    }
}
