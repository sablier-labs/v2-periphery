// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";

import { IAirstream } from "./IAirstream.sol";

interface IAirstreamLockupLinear is IAirstream {
    /// @notice The total streaming duration of each airstream.
    function duration() external view returns (uint40);

    /// @notice The address of the {SablierV2LockupLinear} contract.
    function lockupLinear() external view returns (ISablierV2LockupLinear);
}
