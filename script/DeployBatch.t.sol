// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <0.9.0;

import { BaseScript } from "./Base.s.sol";

import { SablierV2Batch } from "../src/SablierV2Batch.sol";

contract DeployBatch is BaseScript {
    function run() public broadcast returns (SablierV2Batch batch) {
        batch = new SablierV2Batch();
    }
}
