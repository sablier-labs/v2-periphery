// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Integration_Test } from "../../../Integration.t.sol";

import { ISablierV2AirstreamCampaignLL } from "src/interfaces/ISablierV2AirstreamCampaignLL.sol";

contract HasExpired_Integration_Test is Integration_Test {
    function setUp() public virtual override {
        Integration_Test.setUp();
    }

    function test_HasExpired_ExpirationZero() external {
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

    function test_HasExpired_ExpirationLessThanCurrentTime() external whenExpirationNotZero {
        assertFalse(campaignLL.hasExpired(), "campaign expired");
    }

    function test_HasExpired_ExpirationEqualToCurrentTime() external whenExpirationNotZero {
        vm.warp({ timestamp: defaults.EXPIRATION() });
        assertTrue(campaignLL.hasExpired(), "campaign not expired");
    }

    function test_HasExpired_ExpirationGreaterThanCurrentTime() external whenExpirationNotZero {
        vm.warp({ timestamp: defaults.EXPIRATION() + 1 seconds });
        assertTrue(campaignLL.hasExpired(), "campaign not expired");
    }
}
