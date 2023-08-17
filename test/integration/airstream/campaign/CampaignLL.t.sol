// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ISablierV2Lockup } from "@sablier/v2-core/interfaces/ISablierV2Lockup.sol";

import { ISablierV2AirstreamCampaign } from "src/interfaces/ISablierV2AirstreamCampaign.sol";

import { Integration_Test } from "../../Integration.t.sol";

import { Claim_Integration_Test } from "./shared/claim/claim.t.sol";
import { Clawback_Integration_Test } from "./shared/clawback/clawback.t.sol";
import { HasClaimed_Integration_Test } from "./shared/has-claimed/hasClaimed.t.sol";

abstract contract CampaignLL_Integration_Test is Integration_Test {
    function setUp() public virtual override {
        Integration_Test.setUp();
        campaign = ISablierV2AirstreamCampaign(createAirstreamCampaignLL());
        lockup = ISablierV2Lockup(lockupLinear);
        deal({ token: address(asset), to: address(campaign), give: defaults.CAMPAIGN_TOTAL_AMOUNT() });
        vm.label(address(campaign), "campaignLL");
    }
}

contract Claim_CampaignLL_Integration_Test is CampaignLL_Integration_Test, Claim_Integration_Test {
    function setUp() public override(CampaignLL_Integration_Test, Claim_Integration_Test) {
        CampaignLL_Integration_Test.setUp();
        Claim_Integration_Test.setUp();
    }
}

contract Clawback_CampaignLL_Integration_Test is CampaignLL_Integration_Test, Clawback_Integration_Test {
    function setUp() public override(CampaignLL_Integration_Test, Clawback_Integration_Test) {
        CampaignLL_Integration_Test.setUp();
        Clawback_Integration_Test.setUp();
    }
}

contract HasClaimed_CampaignLL_Integration_Test is CampaignLL_Integration_Test, HasClaimed_Integration_Test {
    function setUp() public override(CampaignLL_Integration_Test, HasClaimed_Integration_Test) {
        CampaignLL_Integration_Test.setUp();
        HasClaimed_Integration_Test.setUp();
    }
}
