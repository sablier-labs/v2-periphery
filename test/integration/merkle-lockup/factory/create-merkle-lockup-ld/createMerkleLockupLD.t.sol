// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Errors } from "src/libraries/Errors.sol";
import { ISablierV2MerkleLockupLD } from "src/interfaces/ISablierV2MerkleLockupLD.sol";
import { MerkleLockup } from "src/types/DataTypes.sol";

import { MerkleLockup_Integration_Test } from "../../MerkleLockup.t.sol";

contract CreateMerkleLockupLD_Integration_Test is MerkleLockup_Integration_Test {
    function setUp() public override {
        MerkleLockup_Integration_Test.setUp();
    }

    function test_RevertWhen_CampaignNameTooLong() external {
        MerkleLockup.ConstructorParams memory baseParams = defaults.baseParamsLD();
        string memory ipfsCID = defaults.IPFS_CID();
        uint256 aggregateAmount = defaults.AGGREGATE_AMOUNT();
        uint256 recipientsCount = defaults.RECIPIENTS_COUNT();

        baseParams.name = "this string is longer than 32 characters";

        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierV2MerkleLockup_CampaignNameTooLong.selector, bytes(baseParams.name).length, 32
            )
        );

        merkleLockupFactory.createMerkleLockupLD({
            baseParams: baseParams,
            lockupDynamic: lockupDynamic,
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
        MerkleLockup.ConstructorParams memory baseParams = defaults.baseParamsLD();
        string memory ipfsCID = defaults.IPFS_CID();
        uint256 aggregateAmount = defaults.AGGREGATE_AMOUNT();
        uint256 recipientsCount = defaults.RECIPIENTS_COUNT();

        vm.expectRevert();
        merkleLockupFactory.createMerkleLockupLD({
            baseParams: baseParams,
            lockupDynamic: lockupDynamic,
            ipfsCID: ipfsCID,
            aggregateAmount: aggregateAmount,
            recipientsCount: recipientsCount
        });
    }

    modifier givenNotAlreadyCreated() {
        _;
    }

    function testFuzz_CreateMerkleLockupLD(
        address admin,
        uint40 expiration
    )
        external
        whenCampaignNameIsNotTooLong
        givenNotAlreadyCreated
    {
        vm.assume(admin != users.admin);
        address expectedLockupLD = computeMerkleLockupLDAddress(admin, expiration);

        MerkleLockup.ConstructorParams memory baseParams =
            defaults.baseParams({ admin: admin, merkleRoot: defaults.MERKLE_ROOT_LD(), expiration: expiration });

        vm.expectEmit({ emitter: address(merkleLockupFactory) });
        emit CreateMerkleLockupLD({
            merkleLockupLD: ISablierV2MerkleLockupLD(expectedLockupLD),
            baseParams: baseParams,
            lockupDynamic: lockupDynamic,
            ipfsCID: defaults.IPFS_CID(),
            aggregateAmount: defaults.AGGREGATE_AMOUNT(),
            recipientsCount: defaults.RECIPIENTS_COUNT()
        });

        address actualLockupLD = address(createMerkleLockupLD(admin, expiration));

        assertGt(actualLockupLD.code.length, 0, "MerkleLockupLD contract not created");
        assertEq(actualLockupLD, expectedLockupLD, "MerkleLockupLD contract does not match computed address");
    }
}
