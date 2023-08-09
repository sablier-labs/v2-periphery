// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { ISablierV2LockupDynamic } from "@sablier/v2-core/interfaces/ISablierV2LockupDynamic.sol";
import { UD2x18 } from "@sablier/v2-core/types/Math.sol";
import { LockupDynamic } from "@sablier/v2-core/types/DataTypes.sol";

import { ISablierV2Airstream } from "./ISablierV2Airstream.sol";

interface ISablierV2AirstreamLockupDynamic is ISablierV2Airstream {
    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice The address of the {SablierV2LockupDynamic} contract.
    function lockupDynamic() external view returns (ISablierV2LockupDynamic);

    /// @notice Retrieve a single segment.
    function getSegment(uint256 segmentIndex) external view returns (LockupDynamic.SegmentWithDelta memory);

    /// @notice Retrieve the array of segments.
    function getSegments() external view returns (LockupDynamic.SegmentWithDelta[] memory);
}
