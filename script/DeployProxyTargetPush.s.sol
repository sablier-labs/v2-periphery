// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <0.9.0;

import { BaseScript } from "@sablier/v2-core-script/Base.s.sol";

import { SablierV2ProxyTargetPush } from "../src/SablierV2ProxyTargetPush.sol";

contract DeployProxyTargetPush is BaseScript {
    function run() public broadcast returns (SablierV2ProxyTargetPush targetPush) {
        targetPush = new SablierV2ProxyTargetPush();
    }
}
