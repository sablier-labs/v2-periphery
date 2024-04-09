// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { BaseScript } from "@sablier/v2-core/script/Base.s.sol";

import { SablierV2Batch } from "../src/SablierV2Batch.sol";

/// @notice Deploys {SablierV2Batch} at a deterministic address across chains.
/// @dev Reverts if the contract has already been deployed.
contract DeployDeterministicBatch is BaseScript {
    /// @dev Deploy using Forge CLI.
    function runBroadcast() public virtual broadcast returns (SablierV2Batch batch) {
        batch = _run();
    }

    /// @dev Deploy using Sphinx CLI.
    function runSphinx() public virtual sphinx returns (SablierV2Batch batch) {
        batch = _run();
    }

    function _run() internal returns (SablierV2Batch batch) {
        bytes32 salt = constructCreate2Salt();
        batch = new SablierV2Batch{ salt: salt }();
    }
}
