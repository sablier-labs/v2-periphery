// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ISablierV2AirstreamCampaignLL } from "src/interfaces/ISablierV2AirstreamCampaignLL.sol";

import { Airstream_Integration_Test } from "../../Airstream.t.sol";

contract HasExpired_Integration_Test is Airstream_Integration_Test {
    function setUp() public virtual override {
        Airstream_Integration_Test.setUp();
    }

    function test_HasExpired_ExpirationZero() external {
        ISablierV2AirstreamCampaignLL testCampaign = createAirstreamCampaignLL({ expiration: 0 });
        assertFalse(testCampaign.hasExpired(), "campaign expired");
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
