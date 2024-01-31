// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { Errors } from "src/libraries/Errors.sol";
import { ISablierV2MerkleLockupLL } from "src/interfaces/ISablierV2MerkleLockupLL.sol";
import { MerkleLockup } from "src/types/DataTypes.sol";

import { MerkleLockup_Integration_Test } from "../../MerkleLockup.t.sol";

contract CreateMerkleLockupLL_Integration_Test is MerkleLockup_Integration_Test {
    function setUp() public override {
        MerkleLockup_Integration_Test.setUp();
    }

    function test_RevertWhen_CampaignNameTooLong() external {
        MerkleLockup.ConstructorParams memory baseParams = defaults.baseParams();
        LockupLinear.Durations memory streamDurations = defaults.durations();
        string memory ipfsCID = defaults.IPFS_CID();
        uint256 aggregateAmount = defaults.AGGREGATE_AMOUNT();
        uint256 recipientsCount = defaults.RECIPIENTS_COUNT();

        baseParams.name = "this string is longer than 32 characters";

        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierV2MerkleLockup_CampaignNameTooLong.selector, bytes(baseParams.name).length, 32
            )
        );

        merkleLockupFactory.createMerkleLockupLL({
            baseParams: baseParams,
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

    /// @dev This test works because a default Merkle Lockup contract is deployed in {Integration_Test.setUp}
    function test_RevertGiven_AlreadyCreated() external whenCampaignNameIsNotTooLong {
        MerkleLockup.ConstructorParams memory baseParams = defaults.baseParams();
        LockupLinear.Durations memory streamDurations = defaults.durations();
        string memory ipfsCID = defaults.IPFS_CID();
        uint256 aggregateAmount = defaults.AGGREGATE_AMOUNT();
        uint256 recipientsCount = defaults.RECIPIENTS_COUNT();

        vm.expectRevert();
        merkleLockupFactory.createMerkleLockupLL({
            baseParams: baseParams,
            lockupLinear: lockupLinear,
            streamDurations: streamDurations,
            ipfsCID: ipfsCID,
            aggregateAmount: aggregateAmount,
            recipientsCount: recipientsCount
        });
    }

    modifier givenNotAlreadyCreated() {
        _;
    }

    function testFuzz_CreateMerkleLockupLL(
        address admin,
        uint40 expiration
    )
        external
        whenCampaignNameIsNotTooLong
        givenNotAlreadyCreated
    {
        vm.assume(admin != users.admin);
        address expectedLockupLL = computeMerkleLockupLLAddress(admin, expiration);

        MerkleLockup.ConstructorParams memory baseParams =
            defaults.baseParams({ admin: admin, merkleRoot: defaults.MERKLE_ROOT(), expiration: expiration });

        vm.expectEmit({ emitter: address(merkleLockupFactory) });
        emit CreateMerkleLockupLL({
            merkleLockupLL: ISablierV2MerkleLockupLL(expectedLockupLL),
            baseParams: baseParams,
            lockupLinear: lockupLinear,
            streamDurations: defaults.durations(),
            ipfsCID: defaults.IPFS_CID(),
            aggregateAmount: defaults.AGGREGATE_AMOUNT(),
            recipientsCount: defaults.RECIPIENTS_COUNT()
        });

        address actualLockupLL = address(createMerkleLockupLL(admin, expiration));

        assertGt(actualLockupLL.code.length, 0, "MerkleLockupLL contract not created");
        assertEq(actualLockupLL, expectedLockupLL, "MerkleLockupLL contract does not match computed address");
    }
}
