// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <=0.9.0;

import { BaseScript } from "@sablier/v2-core-script/Base.s.sol";

import { SablierV2Archive } from "../src/SablierV2Archive.sol";

/// @notice Deploys {SablierV2Archive} at a deterministic address across chains.
/// @dev Reverts if the contract has already been deployed.
contract DeployDeterministicArchive is BaseScript {
    /// @dev The presence of the salt instructs Forge to deploy contracts via this deterministic CREATE2 factory:
    /// https://github.com/Arachnid/deterministic-deployment-proxy
    function run(
        uint256 create2Salt,
        address initialAdmin
    )
        public
        virtual
        broadcaster
        returns (SablierV2Archive archive)
    {
        archive = new SablierV2Archive{ salt: bytes32(create2Salt) }(initialAdmin);
    }
}
