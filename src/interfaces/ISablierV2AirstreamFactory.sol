// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { ISablierV2AirstreamLockupDynamic } from "./ISablierV2AirstreamLockupDynamic.sol";
import { ISablierV2AirstreamLockupLinear } from "./ISablierV2AirstreamLockupLinear.sol";

interface ISablierV2AirstreamFactory {
    function createAirstreamLockupDynamic() external returns (ISablierV2AirstreamLockupDynamic);
    function createAirstreamLockupLinear() external returns (ISablierV2AirstreamLockupLinear);
}
