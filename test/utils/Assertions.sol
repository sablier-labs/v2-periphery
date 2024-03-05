// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { PRBMathAssertions } from "@prb/math/test/utils/Assertions.sol";
import { PRBTest } from "@prb/test/src/PRBTest.sol";

import { MerkleLockupLT } from "src/types/DataTypes.sol";

abstract contract Assertions is PRBTest, PRBMathAssertions {
    event LogNamedArray(string key, MerkleLockupLT.TrancheWithPercentage[] tranchesWithPercentages);

    /// @dev Compares two {MerkleLockupLT.TrancheWithPercentage[]} arrays.
    function assertEq(
        MerkleLockupLT.TrancheWithPercentage[] memory a,
        MerkleLockupLT.TrancheWithPercentage[] memory b
    )
        internal
    {
        if (keccak256(abi.encode(a)) != keccak256(abi.encode(b))) {
            emit Log("Error: a == b not satisfied [MerkleLockupLT.TrancheWithPercentage[]]");
            emit LogNamedArray("   Left", b);
            emit LogNamedArray("  Right", a);
            fail();
        }
    }
}
