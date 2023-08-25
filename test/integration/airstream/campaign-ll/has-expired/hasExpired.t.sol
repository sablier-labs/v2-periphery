// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Integration_Test } from "../../../Integration.t.sol";

import { ISablierV2AirstreamCampaignLL } from "src/interfaces/ISablierV2AirstreamCampaignLL.sol";

contract HasExpired_Integration_Test is Integration_Test {
    function setUp() public virtual override {
        Integration_Test.setUp();
    }

    function test_HasExpired_ExiprationZero() external {
        ISablierV2AirstreamCampaignLL _campaignLL = campaignFactory.createAirstreamCampaignLL({
            initialAdmin: users.admin.addr,
            asset: asset,
            merkleRoot: defaults.merkleRoot(),
            cancelable: defaults.CANCELABLE(),
            expiration: 0,
            lockupLinear: lockupLinear,
            airstreamDurations: defaults.durations(),
            ipfsCID: defaults.IPFS_CID(),
            campaignTotalAmount: defaults.CAMPAIGN_TOTAL_AMOUNT(),
            recipientsCount: defaults.RECIPIENTS_COUNT()
        });

        assertFalse(_campaignLL.hasExpired());
    }

    modifier whenExpirationNotZero() {
        _;
    }

    function test_HasExpired_NotGreaterThanCurrentTime() external whenExpirationNotZero {
        assertFalse(campaignLL.hasExpired());
    }

    function test_HasExpired_EqualToCurrentTime() external whenExpirationNotZero {
        vm.warp(defaults.EXPIRATION());
        assertTrue(campaignLL.hasExpired());
    }

    function test_HasExpired_GreaterThanCurrentTime() external whenExpirationNotZero {
        vm.warp(defaults.EXPIRATION() + 1);
        assertTrue(campaignLL.hasExpired());
    }
}
