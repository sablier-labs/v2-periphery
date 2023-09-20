// SPDX-License-Identifier: UNLICENSED
// solhint-disable no-inline-assembly
pragma solidity >=0.8.19 <0.9.0;

import { ISablierV2MerkleStreamer } from "src/interfaces/ISablierV2MerkleStreamer.sol";

import { MerkleStreamer_Integration_Test } from "../../MerkleStreamer.t.sol";

contract GetMerkleStreamers_Integration_Test is MerkleStreamer_Integration_Test {
    function setUp() public override {
        MerkleStreamer_Integration_Test.setUp();
    }

    function test_GetMerkleStreamers_AdminDoesNotHaveMerkleStreamers(address admin) external {
        vm.assume(admin != users.admin.addr);
        ISablierV2MerkleStreamer[] memory array = merkleStreamerFactory.getMerkleStreamers(admin);
        assertEq(array.length, 0, "Merkle streamers array not empty");
    }

    modifier givenAdminHasMerkleStreamers() {
        _;
    }

    function test_GetMerkleStreamers() external givenAdminHasMerkleStreamers {
        ISablierV2MerkleStreamer testStreamerLL = createMerkleStreamerLL(defaults.EXPIRATION() + 1 seconds);
        ISablierV2MerkleStreamer[] memory merkleStreamers = merkleStreamerFactory.getMerkleStreamers(users.admin.addr);
        address[] memory actualArray;
        assembly {
            actualArray := merkleStreamers
        }
        address[] memory expectedArray = new address[](2);
        expectedArray[0] = address(merkleStreamerLL);
        expectedArray[1] = address(testStreamerLL);
        assertEq(actualArray, expectedArray, "Merkle streamers arrays not equal");
    }
}
