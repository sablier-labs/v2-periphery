// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";

import { ISablierV2Airstream } from "./ISablierV2Airstream.sol";

interface ISablierV2AirstreamLockupLinear is ISablierV2Airstream {
    /// @notice The total streaming duration of each airstream.
    function duration() external view returns (uint40);

    /// @notice The address of the {SablierV2LockupLinear} contract.
    function lockupLinear() external view returns (ISablierV2LockupLinear);
}
