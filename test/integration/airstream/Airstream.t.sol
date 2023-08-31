// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { ISablierV2AirstreamCampaignLL } from "src/interfaces/ISablierV2AirstreamCampaignLL.sol";

import { Integration_Test } from "../Integration.t.sol";

abstract contract Airstream_Integration_Test is Integration_Test {
    function setUp() public virtual override {
        Integration_Test.setUp();

        // Create the default airstream campaign.
        campaignLL = createAirstreamCampaignLL();

        // Fund the campaign.
        deal({ token: address(asset), to: address(campaignLL), give: defaults.CAMPAIGN_TOTAL_AMOUNT() });
    }

    function claimLL() internal returns (uint256) {
        return campaignLL.claim({
            index: defaults.INDEX1(),
            recipient: users.recipient1.addr,
            amount: defaults.CLAIM_AMOUNT(),
            merkleProof: defaults.index1Proof()
        });
    }

    function createAirstreamCampaignLL() internal returns (ISablierV2AirstreamCampaignLL) {
        return createAirstreamCampaignLL(users.admin.addr, defaults.EXPIRATION());
    }

    function createAirstreamCampaignLL(address admin) internal returns (ISablierV2AirstreamCampaignLL) {
        return createAirstreamCampaignLL(admin, defaults.EXPIRATION());
    }

    function createAirstreamCampaignLL(uint40 expiration) internal returns (ISablierV2AirstreamCampaignLL) {
        return createAirstreamCampaignLL(users.admin.addr, expiration);
    }

    function createAirstreamCampaignLL(
        address admin,
        uint40 expiration
    )
        internal
        returns (ISablierV2AirstreamCampaignLL)
    {
        return campaignFactory.createAirstreamCampaignLL({
            initialAdmin: admin,
            lockupLinear: lockupLinear,
            asset: asset,
            merkleRoot: defaults.merkleRoot(),
            expiration: expiration,
            cancelable: defaults.CANCELABLE(),
            airstreamDurations: defaults.durations(),
            ipfsCID: defaults.IPFS_CID(),
            campaignTotalAmount: defaults.CAMPAIGN_TOTAL_AMOUNT(),
            recipientsCount: defaults.RECIPIENTS_COUNT()
        });
    }
}
