// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <=0.9.0;

import { BaseScript } from "@sablier/v2-core-script/Base.s.sol";

import { SablierV2ProxyTargetERC20 } from "../src/SablierV2ProxyTargetERC20.sol";

/// @notice Deploys {SablierV2ProxyTargetERC20} at a deterministic address across chains.
/// @dev Reverts if the contract has already been deployed.
contract DeployDeterministicProxyTargetERC20 is BaseScript {
    /// @dev The presence of the salt instructs Forge to deploy contracts via this deterministic CREATE2 factory:
    /// https://github.com/Arachnid/deterministic-deployment-proxy
    function run(string memory create2Salt) public virtual broadcast returns (SablierV2ProxyTargetERC20 targetERC20) {
        targetERC20 = new SablierV2ProxyTargetERC20{ salt: bytes32(abi.encodePacked(create2Salt)) }();
    }
}
