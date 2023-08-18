// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ISablierV2Lockup } from "@sablier/v2-core/src/interfaces/ISablierV2Lockup.sol";

import { ISablierV2AirstreamCampaign } from "src/interfaces/ISablierV2AirstreamCampaign.sol";

import { Integration_Test } from "../../../Integration.t.sol";

import { Claim_Integration_Test } from "../claim/claim.t.sol";
import { Clawback_Integration_Test } from "../clawback/clawback.t.sol";
import { HasClaimed_Integration_Test } from "../has-claimed/hasClaimed.t.sol";

abstract contract CampaignLD_Integration_Test is Integration_Test {
    function setUp() public virtual override {
        Integration_Test.setUp();
        campaign = ISablierV2AirstreamCampaign(createAirstreamCampaignLD());
        lockup = ISablierV2Lockup(lockupDynamic);
        deal({ token: address(asset), to: address(campaign), give: defaults.CAMPAIGN_TOTAL_AMOUNT() });
        vm.label(address(campaign), "Campaign LD");
    }
}

contract Claim_CampaignLD_Integration_Test is CampaignLD_Integration_Test, Claim_Integration_Test {
    function setUp() public override(CampaignLD_Integration_Test, Claim_Integration_Test) {
        CampaignLD_Integration_Test.setUp();
        Claim_Integration_Test.setUp();
    }
}

contract Clawback_CampaignLD_Integration_Test is CampaignLD_Integration_Test, Clawback_Integration_Test {
    function setUp() public override(CampaignLD_Integration_Test, Clawback_Integration_Test) {
        CampaignLD_Integration_Test.setUp();
        Clawback_Integration_Test.setUp();
    }
}

contract HasClaimed_CampaignLD_Integration_Test is CampaignLD_Integration_Test, HasClaimed_Integration_Test {
    function setUp() public override(CampaignLD_Integration_Test, HasClaimed_Integration_Test) {
        CampaignLD_Integration_Test.setUp();
        HasClaimed_Integration_Test.setUp();
    }
}
