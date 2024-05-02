// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { BaseScript } from "./Base.s.sol";

import { SablierV2MerkleLockupFactory } from "../src/SablierV2MerkleLockupFactory.sol";

contract DeployMerkleLockupFactory is BaseScript {
    /// @dev Deploy via Forge.
    function runBroadcast(address admin)
        public
        virtual
        broadcast
        returns (SablierV2MerkleLockupFactory merkleLockupFactory)
    {
        merkleLockupFactory = _run(admin);
    }

    /// @dev Deploy via Sphinx.
    function runSphinx(address admin)
        public
        virtual
        sphinx
        returns (SablierV2MerkleLockupFactory merkleLockupFactory)
    {
        merkleLockupFactory = _run(admin);
    }

    function _run(address admin) internal returns (SablierV2MerkleLockupFactory merkleLockupFactory) {
        merkleLockupFactory = new SablierV2MerkleLockupFactory(msg.sender);
        merkleLockupFactory.configureRebasingAsset(USDB, YIELD_MODE);
        merkleLockupFactory.configureRebasingAsset(WETH, YIELD_MODE);
        merkleLockupFactory.configureYieldAndGas(BLAST, YIELD_MODE, GAS_MODE, admin);
        merkleLockupFactory.transferAdmin(admin);
    }
}
