// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <=0.9.0;

import { BaseScript } from "@sablier/v2-core-script/shared/Base.s.sol";

import { ISablierV2Archive } from "../src/interfaces/ISablierV2Archive.sol";
import { SablierV2ProxyPlugin } from "../src/SablierV2ProxyPlugin.sol";

/// @notice Deploys {SablierV2ProxyPlugin} at a deterministic address across chains.
/// @dev Reverts if the contract has already been deployed.
contract DeployDeterministicProxyPlugin is BaseScript {
    /// @dev The presence of the salt instructs Forge to deploy contracts via this deterministic CREATE2 factory:
    /// https://github.com/Arachnid/deterministic-deployment-proxy
    function run(ISablierV2Archive archive) public virtual broadcaster returns (SablierV2ProxyPlugin plugin) {
        plugin = new SablierV2ProxyPlugin{ salt: ZERO_SALT }(archive);
    }
}
