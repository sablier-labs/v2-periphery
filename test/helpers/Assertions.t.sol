// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { Lockup } from "@sablier/v2-core/types/DataTypes.sol";

abstract contract Assertions is PRBTest {
    event LogArray(bytes4[] value);
    event LogNamedArray(string key, bytes4[] value);

    /// @dev Compares two `bytes4[]` arrays.
    function assertEq(bytes4[] memory a, bytes4[] memory b) internal {
        if (keccak256(abi.encode(a)) != keccak256(abi.encode(b))) {
            emit Log("Error: a == b not satisfied [bytes4[]]");
            emit LogNamedArray("   Left", a);
            emit LogNamedArray("  Right", b);
            fail();
        }
    }

    /// @dev Compares two `bytes4[]` arrays.
    function assertEq(bytes4[] memory a, bytes4[] memory b, string memory err) internal {
        if (keccak256(abi.encode(a)) != keccak256(abi.encode(b))) {
            emit LogNamedString("Error", err);
            emit Log("Error: a == b not satisfied [bytes4[]]");
            emit LogNamedArray("   Left", a);
            emit LogNamedArray("  Right", b);
            fail();
        }
    }

    /// @dev Compares two `Lockup.Status` enum values.
    function assertEq(Lockup.Status a, Lockup.Status b) internal {
        assertEq(uint8(a), uint8(b), "status");
    }

    /// @dev Compares two `Lockup.Status` enum values.
    function assertEq(Lockup.Status a, Lockup.Status b, string memory err) internal {
        assertEq(uint8(a), uint8(b), err);
    }
}
