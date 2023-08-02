// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { ISablierV2LockupDynamic } from "@sablier/v2-core/interfaces/ISablierV2LockupDynamic.sol";
import { UD2x18 } from "@sablier/v2-core/types/Math.sol";

import { ISablierV2Airstream } from "./ISablierV2Airstream.sol";

interface ISablierV2AirstreamLockupDynamic is ISablierV2Airstream {
    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice The address of the {SablierV2LockupDynamic} contract.
    function lockupDynamic() external view returns (ISablierV2LockupDynamic);

    /// @notice The array of segments needed for creating the LockupDynamic stream, which implicitly provides the total
    /// streaming duration of each airstream.
    function segments(uint256 segmentIndex) external view returns (uint128 amount, UD2x18 exponent, uint40 delta);
}
