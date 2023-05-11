// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <0.9.0;

import { BaseScript } from "@sablier/v2-core-script/shared/Base.s.sol";

import { ISablierV2ChainLog } from "../src/interfaces/ISablierV2ChainLog.sol";
import { SablierV2ProxyPlugin } from "../src/SablierV2ProxyPlugin.sol";

contract DeployProxyPlugin is BaseScript {
    function run(ISablierV2ChainLog chainLog) public broadcaster returns (SablierV2ProxyPlugin plugin) {
        plugin = new SablierV2ProxyPlugin(chainLog);
    }
}
