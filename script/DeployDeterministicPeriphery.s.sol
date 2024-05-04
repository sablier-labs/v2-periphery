// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { BaseScript } from "./Base.s.sol";

import { SablierV2BatchLockup } from "../src/SablierV2BatchLockup.sol";
import { SablierV2MerkleLockupFactory } from "../src/SablierV2MerkleLockupFactory.sol";

/// @notice Deploys all V2 Periphery contracts at deterministic addresses across chains, in the following order:
///
/// 1. {SablierV2BatchLockup}
/// 2. {SablierV2MerkleLockupFactory}
///
/// @dev Reverts if any contract has already been deployed.
contract DeployDeterministicPeriphery is BaseScript {
    /// @dev Deploy via Forge.
    function runBroadcast(address admin)
        public
        virtual
        broadcast
        returns (SablierV2BatchLockup batchLockup, SablierV2MerkleLockupFactory merkleLockupFactory)
    {
        (batchLockup, merkleLockupFactory) = _run(admin);
    }

    /// @dev Deploy via Sphinx.
    function runSphinx(address admin)
        public
        virtual
        sphinx
        returns (SablierV2BatchLockup batchLockup, SablierV2MerkleLockupFactory merkleLockupFactory)
    {
        (batchLockup, merkleLockupFactory) = _run(admin);
    }

    function _run(address admin)
        internal
        returns (SablierV2BatchLockup batchLockup, SablierV2MerkleLockupFactory merkleLockupFactory)
    {
        bytes32 salt = constructCreate2Salt();

        batchLockup = new SablierV2BatchLockup{ salt: salt }(msg.sender);

        // Configure Blast mainnet yield and gas modes.
        batchLockup.configureRebasingAsset({ asset: USDB, yieldMode: YIELD_MODE });
        batchLockup.configureRebasingAsset({ asset: WETH, yieldMode: YIELD_MODE });
        batchLockup.configureYieldAndGas({ blast: BLAST, yieldMode: YIELD_MODE, gasMode: GAS_MODE, governor: admin });
        batchLockup.transferAdmin(admin);

        merkleLockupFactory = new SablierV2MerkleLockupFactory{ salt: salt }(msg.sender);

        // Configure Blast mainnet yield and gas modes.
        merkleLockupFactory.configureRebasingAsset({ asset: USDB, yieldMode: YIELD_MODE });
        merkleLockupFactory.configureRebasingAsset({ asset: WETH, yieldMode: YIELD_MODE });
        merkleLockupFactory.configureYieldAndGas({
            blast: BLAST,
            yieldMode: YIELD_MODE,
            gasMode: GAS_MODE,
            governor: admin
        });
        merkleLockupFactory.transferAdmin(admin);
    }
}
