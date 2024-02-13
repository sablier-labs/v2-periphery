// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { BaseScript } from "./Base.s.sol";

import { SablierV2MerkleLockupFactory } from "../src/SablierV2MerkleLockupFactory.sol";

contract DeployMerkleLockupFactory is BaseScript {
    function run() public broadcast returns (SablierV2MerkleLockupFactory merkleLockupFactory) {
        merkleLockupFactory = new SablierV2MerkleLockupFactory();
    }
}
