// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { BaseScript } from "./Base.s.sol";

import { SablierV2BatchLockup } from "../src/SablierV2BatchLockup.sol";

contract DeployBatchLockup is BaseScript {
    /// @dev Deploy via Forge.
    function run(address admin) public virtual broadcast returns (SablierV2BatchLockup batchLockup) {
        batchLockup = new SablierV2BatchLockup(msg.sender);

        // Configure Blast mainnet yield and gas modes.
        batchLockup.configureRebasingAsset({ asset: USDB, yieldMode: YIELD_MODE });
        batchLockup.configureRebasingAsset({ asset: WETH, yieldMode: YIELD_MODE });
        batchLockup.configureYieldAndGas({ blast: BLAST, yieldMode: YIELD_MODE, gasMode: GAS_MODE, governor: admin });
        batchLockup.transferAdmin(admin);
    }
}
