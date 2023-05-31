// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <=0.9.0;

import { BaseScript } from "@sablier/v2-core-script/Base.s.sol";

import { SablierV2Archive } from "../src/SablierV2Archive.sol";
import { SablierV2ProxyPlugin } from "../src/SablierV2ProxyPlugin.sol";
import { SablierV2ProxyTarget } from "../src/SablierV2ProxyTarget.sol";

/// @notice Deploys all V2 Core contracts at deterministic addresses across chains, in the following order:
///
/// 1. {SablierV2Archive}
/// 2. {SablierV2ProxyPlugin}
/// 3. {SablierV2ProxyTarget}
///
/// @dev Reverts if any contract has already been deployed.
contract DeployDeterministicPeriphery is BaseScript {
    /// @dev The presence of the salt instructs Forge to deploy the contract via a deterministic CREATE2 factory.
    /// https://github.com/Arachnid/deterministic-deployment-proxy
    function run(
        uint256 create2Salt,
        address initialAdmin
    )
        public
        virtual
        broadcaster
        returns (SablierV2Archive archive, SablierV2ProxyPlugin plugin, SablierV2ProxyTarget target)
    {
        archive = new SablierV2Archive{ salt: bytes32(create2Salt) }(initialAdmin);
        plugin = new SablierV2ProxyPlugin{ salt: bytes32(create2Salt) }(archive);
        target = new SablierV2ProxyTarget{ salt: bytes32(create2Salt) }();
    }
}
