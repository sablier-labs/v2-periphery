// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <0.9.0;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { Assertions as V2CoreAssertions } from "@sablier/v2-core-test/utils/Assertions.sol";

abstract contract Assertions is PRBTest, V2CoreAssertions {
    event LogArray(bytes4[] value);
    event LogNamedArray(string key, bytes4[] value);

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
}
