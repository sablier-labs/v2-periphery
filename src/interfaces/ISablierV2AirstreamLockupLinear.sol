// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";
import { LockupLinear } from "@sablier/v2-core/types/DataTypes.sol";

import { ISablierV2Airstream } from "./ISablierV2Airstream.sol";

interface ISablierV2AirstreamLockupLinear is ISablierV2Airstream {
    /// @notice The total streaming duration of each airstream.
    function durations() external view returns (uint40 cliff, uint40 duration);

    /// @notice The address of the {SablierV2LockupLinear} contract.
    function lockupLinear() external view returns (ISablierV2LockupLinear);
}
