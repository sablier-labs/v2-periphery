// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { BaseScript } from "./Base.s.sol";

import { SablierV2MerkleLockupFactory } from "../src/SablierV2MerkleLockupFactory.sol";
import { SablierV2Batch } from "../src/SablierV2Batch.sol";

/// @notice Deploys all V2 Periphery contract in the following order:
///
/// 1. {SablierV2Batch}
/// 2. {SablierV2MerkleLockupFactory}
contract DeployPeriphery is BaseScript {
    /// @dev Deploy via Forge.
    function runBroadcast()
        public
        virtual
        broadcast
        returns (SablierV2Batch batch, SablierV2MerkleLockupFactory merkleLockupFactory)
    {
        (batch, merkleLockupFactory) = _run();
    }

    /// @dev Deploy via Sphinx.
    function runSphinx()
        public
        virtual
        sphinx
        returns (SablierV2Batch batch, SablierV2MerkleLockupFactory merkleLockupFactory)
    {
        (batch, merkleLockupFactory) = _run();
    }

    function _run() internal returns (SablierV2Batch batch, SablierV2MerkleLockupFactory merkleLockupFactory) {
        batch = new SablierV2Batch();
        merkleLockupFactory = new SablierV2MerkleLockupFactory();
    }
}
