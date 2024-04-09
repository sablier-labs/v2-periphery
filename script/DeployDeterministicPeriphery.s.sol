// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { BaseScript } from "@sablier/v2-core/script/Base.s.sol";

import { SablierV2Batch } from "../src/SablierV2Batch.sol";
import { SablierV2MerkleLockupFactory } from "../src/SablierV2MerkleLockupFactory.sol";

/// @notice Deploys all V2 Periphery contracts at deterministic addresses across chains, in the following order:
///
/// 1. {SablierV2Batch}
/// 2. {SablierV2MerkleLockupFactory}
///
/// @dev Reverts if any contract has already been deployed.
contract DeployDeterministicPeriphery is BaseScript {
    /// @dev Deploy using Forge CLI.
    function runBroadcast()
        public
        virtual
        broadcast
        returns (SablierV2Batch batch, SablierV2MerkleLockupFactory merkleLockupFactory)
    {
        (batch, merkleLockupFactory) = _run();
    }

    /// @dev Deploy using Sphinx CLI.
    function runSphinx()
        public
        virtual
        sphinx
        returns (SablierV2Batch batch, SablierV2MerkleLockupFactory merkleLockupFactory)
    {
        (batch, merkleLockupFactory) = _run();
    }

    function _run() internal returns (SablierV2Batch batch, SablierV2MerkleLockupFactory merkleLockupFactory) {
        bytes32 salt = constructCreate2Salt();
        batch = new SablierV2Batch{ salt: salt }();
        merkleLockupFactory = new SablierV2MerkleLockupFactory{ salt: salt }();
    }
}
