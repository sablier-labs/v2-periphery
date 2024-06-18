// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { MerkleLockup_Integration_Test } from "../../MerkleLockup.t.sol";

contract ComputeMerkleLT_Integration_Test is MerkleLockup_Integration_Test {
    function testFuzz_ComputeMerkleLT(address admin, uint40 expiration) external view {
        address actualLT = address(
            merkleLockupFactory.computeMerkleLT({
                baseParams: defaults.baseParams(admin, dai, expiration, defaults.MERKLE_ROOT()),
                lockupTranched: lockupTranched,
                tranchesWithPercentages: defaults.tranchesWithPercentages()
            })
        );

        address expectedLT = computeMerkleLTAddress(admin, expiration);

        assertEq(actualLT, expectedLT, "Computed MerkleLT address is not correct");
    }
}
