// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Lockup } from "@sablier/v2-core/types/DataTypes.sol";

import { PRBTest } from "@prb/test/PRBTest.sol";

abstract contract Assertions is PRBTest {
    event LogArray(Lockup.Status[] value);
    event LogNamedArray(string key, Lockup.Status[] value);

    /// @dev Compares two `Lockup.Status` enum values.
    function assertEq(Lockup.Status a, Lockup.Status b) internal {
        assertEq(uint8(a), uint8(b), "status");
    }

    /// @dev Compares two `Lockup.Status[]` enum arrays.
    function assertEq(Lockup.Status[] memory a, Lockup.Status[] memory b) internal {
        if (keccak256(abi.encode(a)) != keccak256(abi.encode(b))) {
            emit Log("Error: a == b not satisfied [Lockup.Status[]]");
            emit LogNamedArray("   Left", a);
            emit LogNamedArray("  Right", b);
            fail();
        }
    }

    /// @dev Compares two `Lockup.Status` enum values.
    function assertEq(Lockup.Status a, Lockup.Status b, string memory err) internal {
        assertEq(uint8(a), uint8(b), err);
    }
}
