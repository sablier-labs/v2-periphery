// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IAirstreamLockupDynamic } from "./IAirstreamLockupDynamic.sol";
import { IAirstreamLockupLinear } from "./IAirstreamLockupLinear.sol";

interface IAirstreamFactory {
    function createAirstreamLockupDynamic() external returns (IAirstreamLockupDynamic);
    function createAirstreamLockupLinear() external returns (IAirstreamLockupLinear);
}
