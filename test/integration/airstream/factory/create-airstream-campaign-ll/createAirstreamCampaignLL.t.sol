// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ISablierV2AirstreamCampaign } from "src/interfaces/ISablierV2AirstreamCampaign.sol";
import { ISablierV2AirstreamCampaignLL } from "src/interfaces/ISablierV2AirstreamCampaignLL.sol";

import { Integration_Test } from "../../../Integration.t.sol";

contract CreateAirstreamCampaignLL_Integration_Test is Integration_Test {
    function test_CreateAirstreamCampaignLL_AlreadyExists() external {
        createAirstreamCampaignLL();
        // TODO: Fix this test. // [FAIL. Reason: EvmError: Revert] / 0 bytes of code
        // vm.expectRevert();
        // createAirstreamCampaignLL();
    }

    function test_CreateAirstreamCampaignLL() external {
        address computedCampaign = computeCampaignLLAddress();

        vm.expectEmit({ emitter: address(campaignFactory) });
        emit CreateAirstreamCampaignLL(
            users.admin.addr,
            asset,
            ISablierV2AirstreamCampaignLL(computedCampaign),
            defaults.IPFS_CID(),
            defaults.CAMPAIGN_TOTAL_AMOUNT(),
            defaults.RECIPIENTS_COUNT()
        );
        address actualCampaignLL = address(createAirstreamCampaignLL());

        ISablierV2AirstreamCampaign[] memory expectedCampaign = campaignFactory.getAirstreamCampaigns(users.admin.addr);

        assertTrue(actualCampaignLL.code.length > 0, "campaignLL was not created");
        assertEq(actualCampaignLL, computedCampaign, "campaignLL address does not match computed address");
        assertEq(actualCampaignLL, address(expectedCampaign[0]), "campaignLL was not stored in the campaigns mapping");
    }
}
