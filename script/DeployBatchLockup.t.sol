// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { BaseScript } from "./Base.s.sol";

import { SablierV2BatchLockup } from "../src/SablierV2BatchLockup.sol";

contract DeployBatchLockup is BaseScript {
    /// @dev Deploy via Forge.
    function runBroadcast(address admin) public virtual broadcast returns (SablierV2BatchLockup batchLockup) {
        batchLockup = _run(admin);
    }

    /// @dev Deploy via Sphinx.
    function runSphinx(address admin) public virtual sphinx returns (SablierV2BatchLockup batchLockup) {
        batchLockup = _run(admin);
    }

    function _run(address admin) internal returns (SablierV2BatchLockup batchLockup) {
        batchLockup = new SablierV2BatchLockup(msg.sender);
        batchLockup.configureYieldAndGas(BLAST, YIELD_MODE, GAS_MODE, admin);
        batchLockup.configureRebasingAsset(USDB, YIELD_MODE);
        batchLockup.configureRebasingAsset(WETH, YIELD_MODE);
        batchLockup.transferAdmin(admin);
    }
}
