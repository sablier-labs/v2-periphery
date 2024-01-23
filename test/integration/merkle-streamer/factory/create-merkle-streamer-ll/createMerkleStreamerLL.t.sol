// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { Errors } from "src/libraries/Errors.sol";
import { ISablierV2MerkleStreamerLL } from "src/interfaces/ISablierV2MerkleStreamerLL.sol";
import { MerkleStreamer } from "src/types/DataTypes.sol";

import { MerkleStreamer_Integration_Test } from "../../MerkleStreamer.t.sol";

contract CreateMerkleStreamerLL_Integration_Test is MerkleStreamer_Integration_Test {
    function setUp() public override {
        MerkleStreamer_Integration_Test.setUp();
    }

    function test_RevertWhen_CampaignNameTooLong() external {
        MerkleStreamer.ConstructorParams memory params = defaults.constructorParams();
        LockupLinear.Durations memory streamDurations = defaults.durations();
        string memory ipfsCID = defaults.IPFS_CID();
        uint256 aggregateAmount = defaults.AGGREGATE_AMOUNT();
        uint256 recipientsCount = defaults.RECIPIENTS_COUNT();

        params.name = "this string is longer than 32 characters";

        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierV2MerkleStreamer_CampaignNameTooLong.selector, bytes(params.name).length, 32
            )
        );

        merkleStreamerFactory.createMerkleStreamerLL({
            params: params,
            lockupLinear: lockupLinear,
            streamDurations: streamDurations,
            ipfsCID: ipfsCID,
            aggregateAmount: aggregateAmount,
            recipientsCount: recipientsCount
        });
    }

    modifier whenCampaignNameIsNotTooLong() {
        _;
    }

    /// @dev This test works because a default Merkle streamer is deployed in {Integration_Test.setUp}
    function test_RevertGiven_AlreadyDeployed() external whenCampaignNameIsNotTooLong {
        MerkleStreamer.ConstructorParams memory params = defaults.constructorParams();
        LockupLinear.Durations memory streamDurations = defaults.durations();
        string memory ipfsCID = defaults.IPFS_CID();
        uint256 aggregateAmount = defaults.AGGREGATE_AMOUNT();
        uint256 recipientsCount = defaults.RECIPIENTS_COUNT();

        vm.expectRevert();
        merkleStreamerFactory.createMerkleStreamerLL({
            params: params,
            lockupLinear: lockupLinear,
            streamDurations: streamDurations,
            ipfsCID: ipfsCID,
            aggregateAmount: aggregateAmount,
            recipientsCount: recipientsCount
        });
    }

    modifier givenNotAlreadyDeployed() {
        _;
    }

    function testFuzz_CreateMerkleStreamerLL(
        address admin,
        uint40 expiration
    )
        external
        givenNotAlreadyDeployed
        whenCampaignNameIsNotTooLong
    {
        vm.assume(admin != users.admin);
        address expectedStreamerLL = computeMerkleStreamerLLAddress(admin, expiration);

        vm.expectEmit({ emitter: address(merkleStreamerFactory) });
        emit CreateMerkleStreamerLL({
            merkleStreamer: ISablierV2MerkleStreamerLL(expectedStreamerLL),
            admin: admin,
            asset: asset,
            name: defaults.NAME(),
            merkleRoot: defaults.MERKLE_ROOT(),
            expiration: expiration,
            cancelable: defaults.CANCELABLE(),
            transferable: defaults.TRANSFERABLE(),
            lockupLinear: lockupLinear,
            streamDurations: defaults.durations(),
            ipfsCID: defaults.IPFS_CID(),
            aggregateAmount: defaults.AGGREGATE_AMOUNT(),
            recipientsCount: defaults.RECIPIENTS_COUNT()
        });

        address actualStreamerLL = address(createMerkleStreamerLL(admin, expiration));

        assertGt(actualStreamerLL.code.length, 0, "MerkleStreamerLL contract not created");
        assertEq(actualStreamerLL, expectedStreamerLL, "MerkleStreamerLL contract does not match computed address");
    }
}
