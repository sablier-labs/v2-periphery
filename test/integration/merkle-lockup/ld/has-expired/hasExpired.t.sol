// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { ISablierV2MerkleLockupLD } from "src/interfaces/ISablierV2MerkleLockupLD.sol";

import { MerkleLockup_Integration_Test } from "../../MerkleLockup.t.sol";

contract HasExpiredLD_Integration_Test is MerkleLockup_Integration_Test {
    function setUp() public virtual override {
        MerkleLockup_Integration_Test.setUp();
    }

    function test_HasExpired_ExpirationZero() external {
        ISablierV2MerkleLockupLD testLockup = createMerkleLockupLD({ expiration: 0 });
        assertFalse(testLockup.hasExpired(), "campaign expired");
    }

    modifier whenExpirationNotZero() {
        _;
    }

    function test_HasExpired_ExpirationLessThanCurrentTime() external whenExpirationNotZero {
        assertFalse(merkleLockupLD.hasExpired(), "campaign expired");
    }

    function test_HasExpired_ExpirationEqualToCurrentTime() external whenExpirationNotZero {
        vm.warp({ timestamp: defaults.EXPIRATION() });
        assertTrue(merkleLockupLD.hasExpired(), "campaign not expired");
    }

    function test_HasExpired_ExpirationGreaterThanCurrentTime() external whenExpirationNotZero {
        vm.warp({ timestamp: defaults.EXPIRATION() + 1 seconds });
        assertTrue(merkleLockupLD.hasExpired(), "campaign not expired");
    }
}
