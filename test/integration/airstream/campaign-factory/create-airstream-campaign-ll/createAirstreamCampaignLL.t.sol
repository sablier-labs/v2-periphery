// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { ISablierV2AirstreamCampaignLL } from "src/interfaces/ISablierV2AirstreamCampaignLL.sol";

import { Integration_Test } from "../../../Integration.t.sol";

contract CreateAirstreamCampaignLL_Integration_Test is Integration_Test {
    function setUp() public override {
        Integration_Test.setUp();
    }

    function test_CreateAirstreamCampaignLL_AlreadyExists() external {
        bytes32 merkleRoot = defaults.merkleRoot();
        bool cancelable = defaults.CANCELABLE();
        uint40 expiration = defaults.EXPIRATION();
        LockupLinear.Durations memory durations = defaults.durations();
        string memory ipfsCID = defaults.IPFS_CID();
        uint256 campaignAmount = defaults.CAMPAIGN_TOTAL_AMOUNT();
        uint256 recipientsCount = defaults.RECIPIENTS_COUNT();

        vm.expectRevert();
        campaignFactory.createAirstreamCampaignLL(
            users.admin.addr,
            asset,
            merkleRoot,
            cancelable,
            expiration,
            lockupLinear,
            durations,
            ipfsCID,
            campaignAmount,
            recipientsCount
        );
    }

    function test_CreateAirstreamCampaignLL(address admin) external {
        vm.assume(admin != users.admin.addr);
        address computedCampaignLL = computeCampaignLLAddress(admin);

        vm.expectEmit({ emitter: address(campaignFactory) });
        emit CreateAirstreamCampaignLL(
            admin,
            asset,
            ISablierV2AirstreamCampaignLL(computedCampaignLL),
            defaults.IPFS_CID(),
            defaults.CAMPAIGN_TOTAL_AMOUNT(),
            defaults.RECIPIENTS_COUNT()
        );
        address actualCampaignLL = address(createAirstreamCampaignLL(admin));

        ISablierV2AirstreamCampaignLL[] memory expectedCampaign = campaignFactory.getAirstreamCampaigns(admin);

        assertTrue(actualCampaignLL.code.length > 0, "campaignLL was not created");
        assertEq(actualCampaignLL, computedCampaignLL, "campaignLL address does not match computed address");
        assertEq(actualCampaignLL, address(expectedCampaign[0]), "campaignLL was not stored in the campaigns mapping");
    }
}
