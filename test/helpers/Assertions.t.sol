// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { Lockup } from "@sablier/v2-core/types/DataTypes.sol";

abstract contract Assertions is PRBTest {
    /// @dev Compares two `Lockup.Status` enum values.
    function assertEq(Lockup.Status a, Lockup.Status b) internal {
        assertEq(uint8(a), uint8(b), "status");
    }

    /// @dev Compares two `Lockup.Status` enum values.
    function assertEq(Lockup.Status a, Lockup.Status b, string memory err) internal {
        assertEq(uint8(a), uint8(b), err);
    }
}
