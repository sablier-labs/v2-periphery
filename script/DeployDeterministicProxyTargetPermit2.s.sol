// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <=0.9.0;

import { BaseScript } from "@sablier/v2-core-script/Base.s.sol";
import { IAllowanceTransfer } from "@uniswap/permit2/interfaces/IAllowanceTransfer.sol";

import { SablierV2ProxyTargetPermit2 } from "../src/SablierV2ProxyTargetPermit2.sol";

/// @notice Deploys {SablierV2ProxyTargetPermit2} at a deterministic address across chains.
/// @dev Reverts if the contract has already been deployed.
contract DeployDeterministicProxyTargetPermit2 is BaseScript {
    /// @dev The presence of the salt instructs Forge to deploy contracts via this deterministic CREATE2 factory:
    /// https://github.com/Arachnid/deterministic-deployment-proxy
    function run(
        string memory create2Salt,
        IAllowanceTransfer permit2
    )
        public
        virtual
        broadcast
        returns (SablierV2ProxyTargetPermit2 targetPermit2)
    {
        targetPermit2 = new SablierV2ProxyTargetPermit2{ salt: bytes32(abi.encodePacked(create2Salt)) }(permit2);
    }
}
