// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <0.9.0;

import { BaseScript } from "@sablier/v2-core-script/shared/Base.s.sol";

import { SablierV2ProxyTarget } from "../src/SablierV2ProxyTarget.sol";

contract DeployProxyTarget is BaseScript {
    function run() public broadcaster returns (SablierV2ProxyTarget target) {
        target = new SablierV2ProxyTarget();
    }
}
