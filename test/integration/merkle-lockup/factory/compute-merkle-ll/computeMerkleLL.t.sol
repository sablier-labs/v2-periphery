// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { MerkleLockup_Integration_Test } from "../../MerkleLockup.t.sol";

contract ComputeMerkleLL_Integration_Test is MerkleLockup_Integration_Test {
    function testFuzz_ComputeMerkleLL(address admin, uint40 expiration) external view {
        address actualLL = address(
            merkleLockupFactory.computeMerkleLL({
                baseParams: defaults.baseParams(admin, dai, expiration, defaults.MERKLE_ROOT()),
                lockupLinear: lockupLinear,
                streamDurations: defaults.durations()
            })
        );

        address expectedLL = computeMerkleLLAddress(admin, expiration);

        assertEq(actualLL, expectedLL, "Computed MerkleLL address is not correct");
    }
}
