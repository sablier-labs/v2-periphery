// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ISablierV2AirstreamCampaignLL } from "src/interfaces/ISablierV2AirstreamCampaignLL.sol";

import { Integration_Test } from "../../../Integration.t.sol";

contract GetAirstreamCampaigns_Integration_Test is Integration_Test {
    function setUp() public override {
        Integration_Test.setUp();
    }

    function test_GetAirstreamCampaigns_Empty(address admin) external {
        vm.assume(admin != users.admin.addr);
        ISablierV2AirstreamCampaignLL[] memory campaigns = campaignFactory.getAirstreamCampaigns(admin);
        assertTrue(campaigns.length == 0, "campaigns arrays not empty");
    }

    function test_GetAirstreamCampaigns() external {
        ISablierV2AirstreamCampaignLL[] memory campaigns = campaignFactory.getAirstreamCampaigns(users.admin.addr);
        address actualCampaignLL = address(campaigns[0]);
        address expectedCampaignLL = address(campaignLL);
        assertEq(actualCampaignLL, expectedCampaignLL, "getAirstreamCampaigns");
    }
}
