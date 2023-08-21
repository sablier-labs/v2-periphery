// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <0.9.0;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { Lockup, LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

abstract contract Assertions is PRBTest {
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

    /// @dev Compares two `Lockup.Status` enum values.
    function assertEq(Lockup.Status a, Lockup.Status b) internal {
        assertEq(uint256(a), uint256(b), "status");
    }

    /// @dev Compares two `Lockup.Status` enum values.
    function assertEq(Lockup.Status a, Lockup.Status b, string memory err) internal {
        assertEq(uint256(a), uint256(b), err);
    }

    /// @dev Compares two {LockupLinear.Stream} struct entities.
    function assertEq(LockupLinear.Stream memory a, LockupLinear.Stream memory b) internal {
        assertEq(a.amounts.deposited, b.amounts.deposited);
        assertEq(a.amounts.refunded, b.amounts.refunded);
        assertEq(a.amounts.withdrawn, b.amounts.withdrawn);
        assertEq(address(a.asset), address(b.asset), "asset");
        assertEq(a.cliffTime, b.cliffTime, "cliffTime");
        assertEq(a.endTime, b.endTime, "endTime");
        assertEq(a.isCancelable, b.isCancelable, "isCancelable");
        assertEq(a.isDepleted, b.isDepleted, "isDepleted");
        assertEq(a.isStream, b.isStream, "isStream");
        assertEq(a.sender, b.sender, "sender");
        assertEq(a.startTime, b.startTime, "startTime");
        assertEq(a.wasCanceled, b.wasCanceled, "wasCanceled");
    }
}
