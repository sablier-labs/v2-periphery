// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <=0.9.0;

import { BaseScript } from "@sablier/v2-core-script/Base.s.sol";

import { SablierV2ProxyTargetApprove } from "../src/SablierV2ProxyTargetApprove.sol";

/// @notice Deploys {SablierV2ProxyTargetApprove} at a deterministic address across chains.
/// @dev Reverts if the contract has already been deployed.
contract DeployDeterministicProxyTargetApprove is BaseScript {
    /// @dev The presence of the salt instructs Forge to deploy contracts via this deterministic CREATE2 factory:
    /// https://github.com/Arachnid/deterministic-deployment-proxy
    function run(string memory create2Salt)
        public
        virtual
        broadcast
        returns (SablierV2ProxyTargetApprove targetApprove)
    {
        targetApprove = new SablierV2ProxyTargetApprove{ salt: bytes32(abi.encodePacked(create2Salt)) }();
    }
}
