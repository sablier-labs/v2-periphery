// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { ISablierV2MerkleStreamerLL } from "src/interfaces/ISablierV2MerkleStreamerLL.sol";

import { MerkleStreamer_Integration_Test } from "../../MerkleStreamer.t.sol";

contract CreateMerkleStreamerLL_Integration_Test is MerkleStreamer_Integration_Test {
    function setUp() public override {
        MerkleStreamer_Integration_Test.setUp();
    }

    /// @dev This test works because a default Merkle streamer is deployed in {Integration_Test.setUp}
    function test_RevertGiven_AlreadyDeployed() external {
        string memory ipfsCID = defaults.IPFS_CID();
        uint256 aggregateAmount = defaults.AGGREGATE_AMOUNT();
        uint256 recipientsCount = defaults.RECIPIENTS_COUNT();

        vm.expectRevert();
        merkleStreamerFactory.createMerkleStreamerLL({
            createLLParams: defaultCreateLLParams,
            ipfsCID: ipfsCID,
            aggregateAmount: aggregateAmount,
            recipientsCount: recipientsCount
        });
    }

    modifier givenNotAlreadyDeployed() {
        _;
    }

    function testFuzz_CreateMerkleStreamerLL(address admin, uint40 expiration) external givenNotAlreadyDeployed {
        vm.assume(admin != users.admin);
        address expectedStreamerLL = computeMerkleStreamerLLAddress(admin, expiration);

        vm.expectEmit({ emitter: address(merkleStreamerFactory) });
        emit CreateMerkleStreamerLL({
            merkleStreamer: ISablierV2MerkleStreamerLL(expectedStreamerLL),
            admin: admin,
            lockupLinear: lockupLinear,
            asset: asset,
            name: defaults.NAME_STRING(),
            merkleRoot: defaults.MERKLE_ROOT(),
            expiration: expiration,
            streamDurations: defaults.durations(),
            cancelable: defaults.CANCELABLE(),
            transferable: defaults.TRANSFERABLE(),
            ipfsCID: defaults.IPFS_CID(),
            aggregateAmount: defaults.AGGREGATE_AMOUNT(),
            recipientsCount: defaults.RECIPIENTS_COUNT()
        });

        address actualStreamerLL = address(createMerkleStreamerLL(admin, expiration));

        assertGt(actualStreamerLL.code.length, 0, "MerkleStreamerLL contract not created");
        assertEq(actualStreamerLL, expectedStreamerLL, "MerkleStreamerLL contract does not match computed address");
    }
}
