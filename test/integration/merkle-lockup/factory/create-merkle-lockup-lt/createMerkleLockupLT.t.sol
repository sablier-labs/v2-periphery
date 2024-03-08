// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { ud2x18 } from "@prb/math/src/UD2x18.sol";

import { Errors } from "src/libraries/Errors.sol";
import { ISablierV2MerkleLockupLT } from "src/interfaces/ISablierV2MerkleLockupLT.sol";
import { MerkleLockup, MerkleLockupLT } from "src/types/DataTypes.sol";

import { MerkleLockup_Integration_Test } from "../../MerkleLockup.t.sol";

contract CreateMerkleLockupLT_Integration_Test is MerkleLockup_Integration_Test {
    function setUp() public override {
        MerkleLockup_Integration_Test.setUp();
    }

    modifier whenPercentagesSumIsNotOneHundred() {
        _;
    }

    function test_RevertWhen_PercentageSumLessThanOneHundred() external whenPercentagesSumIsNotOneHundred {
        MerkleLockup.ConstructorParams memory baseParams = defaults.baseParams();
        uint256 aggregateAmount = defaults.AGGREGATE_AMOUNT();
        uint256 recipientsCount = defaults.RECIPIENTS_COUNT();

        MerkleLockupLT.TrancheWithPercentage[] memory tranchesWithPercentages = defaults.tranchesWithPercentages();
        tranchesWithPercentages[0].unlockPercentage = ud2x18(0.05e18);

        uint256 percentageSum = tranchesWithPercentages[0].unlockPercentage.intoUint256()
            + tranchesWithPercentages[1].unlockPercentage.intoUint256();

        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierV2MerkleLockupFactory_PercentageSumNotEqualOneHundred.selector, percentageSum
            )
        );

        merkleLockupFactory.createMerkleLockupLT({
            baseParams: baseParams,
            lockupTranched: lockupTranched,
            tranchesWithPercentages: tranchesWithPercentages,
            aggregateAmount: aggregateAmount,
            recipientsCount: recipientsCount
        });
    }

    function test_RevertWhen_PercentageSumGreaterThanOneHundred() external whenPercentagesSumIsNotOneHundred {
        MerkleLockup.ConstructorParams memory baseParams = defaults.baseParams();
        uint256 aggregateAmount = defaults.AGGREGATE_AMOUNT();
        uint256 recipientsCount = defaults.RECIPIENTS_COUNT();

        MerkleLockupLT.TrancheWithPercentage[] memory tranchesWithPercentages = defaults.tranchesWithPercentages();
        tranchesWithPercentages[0].unlockPercentage = ud2x18(0.75e18);

        uint256 percentageSum = tranchesWithPercentages[0].unlockPercentage.intoUint256()
            + tranchesWithPercentages[1].unlockPercentage.intoUint256();

        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierV2MerkleLockupFactory_PercentageSumNotEqualOneHundred.selector, percentageSum
            )
        );

        merkleLockupFactory.createMerkleLockupLT({
            baseParams: baseParams,
            lockupTranched: lockupTranched,
            tranchesWithPercentages: tranchesWithPercentages,
            aggregateAmount: aggregateAmount,
            recipientsCount: recipientsCount
        });
    }

    modifier whenPercentagesSumIsOneHundred() {
        _;
    }

    function test_RevertWhen_CampaignNameTooLong() external whenPercentagesSumIsOneHundred {
        MerkleLockup.ConstructorParams memory baseParams = defaults.baseParams();
        MerkleLockupLT.TrancheWithPercentage[] memory tranchesWithPercentages = defaults.tranchesWithPercentages();
        uint256 aggregateAmount = defaults.AGGREGATE_AMOUNT();
        uint256 recipientsCount = defaults.RECIPIENTS_COUNT();

        baseParams.name = "this string is longer than 32 characters";

        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierV2MerkleLockup_CampaignNameTooLong.selector, bytes(baseParams.name).length, 32
            )
        );

        merkleLockupFactory.createMerkleLockupLT({
            baseParams: baseParams,
            lockupTranched: lockupTranched,
            tranchesWithPercentages: tranchesWithPercentages,
            aggregateAmount: aggregateAmount,
            recipientsCount: recipientsCount
        });
    }

    modifier whenCampaignNameIsNotTooLong() {
        _;
    }

    /// @dev This test works because a default Merkle Lockup contract is deployed in {Integration_Test.setUp}
    function test_RevertGiven_AlreadyCreated() external whenPercentagesSumIsOneHundred whenCampaignNameIsNotTooLong {
        MerkleLockup.ConstructorParams memory baseParams = defaults.baseParams();
        MerkleLockupLT.TrancheWithPercentage[] memory tranchesWithPercentages = defaults.tranchesWithPercentages();
        uint256 aggregateAmount = defaults.AGGREGATE_AMOUNT();
        uint256 recipientsCount = defaults.RECIPIENTS_COUNT();

        vm.expectRevert();
        merkleLockupFactory.createMerkleLockupLT({
            baseParams: baseParams,
            lockupTranched: lockupTranched,
            tranchesWithPercentages: tranchesWithPercentages,
            aggregateAmount: aggregateAmount,
            recipientsCount: recipientsCount
        });
    }

    modifier givenNotAlreadyCreated() {
        _;
    }

    function testFuzz_CreateMerkleLockupLT(
        address admin,
        uint40 expiration
    )
        external
        whenPercentagesSumIsOneHundred
        whenCampaignNameIsNotTooLong
        givenNotAlreadyCreated
    {
        vm.assume(admin != users.admin);
        address expectedLockupLT = computeMerkleLockupLTAddress(admin, expiration);

        MerkleLockup.ConstructorParams memory baseParams = defaults.baseParams({
            admin: admin,
            asset_: dai,
            merkleRoot: defaults.MERKLE_ROOT(),
            expiration: expiration
        });

        vm.expectEmit({ emitter: address(merkleLockupFactory) });
        emit CreateMerkleLockupLT({
            merkleLockupLT: ISablierV2MerkleLockupLT(expectedLockupLT),
            baseParams: baseParams,
            lockupTranched: lockupTranched,
            tranchesWithPercentages: defaults.tranchesWithPercentages(),
            aggregateAmount: defaults.AGGREGATE_AMOUNT(),
            recipientsCount: defaults.RECIPIENTS_COUNT()
        });

        address actualLockupLT = address(createMerkleLockupLT(admin, expiration));

        assertGt(actualLockupLT.code.length, 0, "MerkleLockupLT contract not created");
        assertEq(actualLockupLT, expectedLockupLT, "MerkleLockupLT contract does not match computed address");
    }
}
