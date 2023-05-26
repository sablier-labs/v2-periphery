// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <0.9.0;

import { BaseScript } from "@sablier/v2-core-script/shared/Base.s.sol";

import { SablierV2Archive } from "../src/SablierV2Archive.sol";
import { SablierV2ProxyPlugin } from "../src/SablierV2ProxyPlugin.sol";
import { SablierV2ProxyTarget } from "../src/SablierV2ProxyTarget.sol";

contract DeployPeriphery {
    function run(address initialAdmin)
        public
        returns (SablierV2Archive archive, SablierV2ProxyPlugin plugin, SablierV2ProxyTarget target)
    {
        archive = new SablierV2Archive(initialAdmin);
        plugin = new SablierV2ProxyPlugin(archive);
        target = new SablierV2ProxyTarget();
    }
}
