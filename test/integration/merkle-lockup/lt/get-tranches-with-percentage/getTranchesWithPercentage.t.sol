// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { MerkleLockupLT } from "src/types/DataTypes.sol";

import { MerkleLockup_Integration_Test } from "../../MerkleLockup.t.sol";

contract GetTranchesWithPercentages_Integration_Test is MerkleLockup_Integration_Test {
    function setUp() public virtual override {
        MerkleLockup_Integration_Test.setUp();
    }

    function test_GetTranchesWithPercentages() external {
        MerkleLockupLT.TrancheWithPercentage[] memory actualTranchesWithPercentages =
            merkleLockupLT.getTranchesWithPercentages();
        MerkleLockupLT.TrancheWithPercentage[] memory expectedTranchesWithPercentages =
            defaults.tranchesWithPercentages();
        assertEq(actualTranchesWithPercentages, expectedTranchesWithPercentages);
    }
}
