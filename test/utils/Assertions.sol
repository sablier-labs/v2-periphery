// SPDX-License-Identifier: GPL-3.0-or-later
// solhint-disable event-name-camelcase
pragma solidity >=0.8.22;

import { PRBMathAssertions } from "@prb/math/test/utils/Assertions.sol";

import { MerkleLockupLT } from "src/types/DataTypes.sol";

abstract contract Assertions is PRBMathAssertions {
    event log_named_array(string key, MerkleLockupLT.TrancheWithPercentage[] tranchesWithPercentages);

    /// @dev Compares two {MerkleLockupLT.TrancheWithPercentage} arrays.
    function assertEq(
        MerkleLockupLT.TrancheWithPercentage[] memory a,
        MerkleLockupLT.TrancheWithPercentage[] memory b
    )
        internal
    {
        if (keccak256(abi.encode(a)) != keccak256(abi.encode(b))) {
            emit log("Error: a == b not satisfied [MerkleLockupLT.TrancheWithPercentage[]]");
            emit log_named_array("   Left", a);
            emit log_named_array("  Right", b);
            fail();
        }
    }

    /// @dev Compares two {MerkleLockupLT.TrancheWithPercentage} arrays.
    function assertEq(
        MerkleLockupLT.TrancheWithPercentage[] memory a,
        MerkleLockupLT.TrancheWithPercentage[] memory b,
        string memory err
    )
        internal
    {
        if (keccak256(abi.encode(a)) != keccak256(abi.encode(b))) {
            emit log_named_string("Error", err);
            assertEq(a, b);
        }
    }
}
