// SPDX-License-Identifier: UNLICENSED
// solhint-disable no-inline-assembly
pragma solidity >=0.8.19 <0.9.0;

import { ISablierV2AirstreamCampaignLL } from "src/interfaces/ISablierV2AirstreamCampaignLL.sol";

import { Airstream_Integration_Test } from "../../Airstream.t.sol";

contract GetAirstreamCampaigns_Integration_Test is Airstream_Integration_Test {
    function setUp() public override {
        Airstream_Integration_Test.setUp();
    }

    function test_GetAirstreamCampaigns_AdminDoesNotHaveCampaigns(address admin) external {
        vm.assume(admin != users.admin.addr);
        ISablierV2AirstreamCampaignLL[] memory campaigns = campaignFactory.getAirstreamCampaigns(admin);
        assertEq(campaigns.length, 0, "campaigns arrays not empty");
    }

    modifier givenAdminHasCampaigns() {
        _;
    }

    function test_GetAirstreamCampaigns() external givenAdminHasCampaigns {
        ISablierV2AirstreamCampaignLL testCampaignLL = createAirstreamCampaignLL(defaults.EXPIRATION() + 1 seconds);
        ISablierV2AirstreamCampaignLL[] memory campaigns = campaignFactory.getAirstreamCampaigns(users.admin.addr);
        address[] memory actualCampaignLL;
        assembly {
            actualCampaignLL := campaigns
        }
        address[] memory expectedCampaigns = new address[](2);
        expectedCampaigns[0] = address(campaignLL);
        expectedCampaigns[1] = address(testCampaignLL);
        assertEq(actualCampaignLL, expectedCampaigns, "getAirstreamCampaigns");
    }
}
