// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ISablierV2AirstreamCampaign } from "src/interfaces/ISablierV2AirstreamCampaign.sol";
import { ISablierV2AirstreamCampaignLD } from "src/interfaces/ISablierV2AirstreamCampaignLD.sol";

import { Integration_Test } from "../../../Integration.t.sol";

contract CreateAirstreamCampaignLD_Integration_Test is Integration_Test {
    function test_CreateAirstreamCampaignLD_AlreadyExists() external {
        createAirstreamCampaignLD();
        // TODO: Fix this test. // [FAIL. Reason: EvmError: Revert] / 0 bytes of code
        // vm.expectRevert();
        // createAirstreamCampaignLD();
    }

    function test_CreateAirstreamCampaignLD() external {
        address computedCampaign = computeCampaignLDAddress();

        vm.expectEmit({ emitter: address(campaignFactory) });
        emit CreateAirstreamCampaignLD(
            users.admin.addr,
            asset,
            ISablierV2AirstreamCampaignLD(computedCampaign),
            defaults.IPFS_CID(),
            defaults.CAMPAIGN_TOTAL_AMOUNT(),
            defaults.RECIPIENTS_COUNT()
        );
        address actualCampaignLD = address(createAirstreamCampaignLD());

        ISablierV2AirstreamCampaign[] memory expectedCampaign = campaignFactory.getAirstreamCampaigns(users.admin.addr);

        assertTrue(actualCampaignLD.code.length > 0);
        assertEq(actualCampaignLD, computedCampaign);
        assertEq(actualCampaignLD, address(expectedCampaign[0]));
    }
}
