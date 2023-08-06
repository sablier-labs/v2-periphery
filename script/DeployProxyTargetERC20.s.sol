// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <0.9.0;

import { BaseScript } from "@sablier/v2-core-script/Base.s.sol";

import { SablierV2ProxyTargetERC20 } from "../src/SablierV2ProxyTargetERC20.sol";

contract DeployProxyTargetERC20 is BaseScript {
    function run() public broadcast returns (SablierV2ProxyTargetERC20 target) {
        target = new SablierV2ProxyTargetERC20();
    }
}
