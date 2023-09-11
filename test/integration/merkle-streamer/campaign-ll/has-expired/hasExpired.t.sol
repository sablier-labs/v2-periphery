// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ISablierV2MerkleStreamerLL } from "src/interfaces/ISablierV2MerkleStreamerLL.sol";

import { MerkleStreamer_Integration_Test } from "../../MerkleStreamer.t.sol";

contract HasExpired_Integration_Test is MerkleStreamer_Integration_Test {
    function setUp() public virtual override {
        MerkleStreamer_Integration_Test.setUp();
    }

    function test_HasExpired_ExpirationZero() external {
        ISablierV2MerkleStreamerLL testStreamer = createMerkleStreamerLL({ expiration: 0 });
        assertFalse(testStreamer.hasExpired(), "campaign expired");
    }

    modifier whenExpirationNotZero() {
        _;
    }

    function test_HasExpired_ExpirationLessThanCurrentTime() external whenExpirationNotZero {
        assertFalse(merkleStreamerLL.hasExpired(), "campaign expired");
    }

    function test_HasExpired_ExpirationEqualToCurrentTime() external whenExpirationNotZero {
        vm.warp({ timestamp: defaults.EXPIRATION() });
        assertTrue(merkleStreamerLL.hasExpired(), "campaign not expired");
    }

    function test_HasExpired_ExpirationGreaterThanCurrentTime() external whenExpirationNotZero {
        vm.warp({ timestamp: defaults.EXPIRATION() + 1 seconds });
        assertTrue(merkleStreamerLL.hasExpired(), "campaign not expired");
    }
}
