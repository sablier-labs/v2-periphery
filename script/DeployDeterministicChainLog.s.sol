// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <=0.9.0;

import { BaseScript } from "@sablier/v2-core-script/shared/Base.s.sol";

import { SablierV2ChainLog } from "../src/SablierV2ChainLog.sol";

/// @notice Deploys {SablierV2ChainLog} at a deterministic address across chains.
/// @dev Reverts if the contract has already been deployed.
contract DeployDeterministicChainLog is BaseScript {
    /// @dev The presence of the salt instructs Forge to deploy contracts via this deterministic CREATE2 factory:
    /// https://github.com/Arachnid/deterministic-deployment-proxy
    function run(address initialAdmin) public virtual broadcaster returns (SablierV2ChainLog chainLog) {
        chainLog = new SablierV2ChainLog{ salt: ZERO_SALT }(initialAdmin);
    }
}
