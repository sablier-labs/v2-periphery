// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <0.9.0;

import { BaseScript } from "@sablier/v2-core-script/shared/Base.s.sol";

import { SablierV2ChainLog } from "../src/SablierV2ChainLog.sol";

contract DeployChainLog is BaseScript {
    function run(address initialAdmin) public broadcaster returns (SablierV2ChainLog chainLog) {
        chainLog = new SablierV2ChainLog(initialAdmin);
    }
}
