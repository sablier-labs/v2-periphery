// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <0.9.0;

import { BaseScript } from "@sablier/v2-core-script/Base.s.sol";

import { SablierV2ProxyTargetApprove } from "../src/SablierV2ProxyTargetApprove.sol";

contract DeployProxyTargetApprove is BaseScript {
    function run() public broadcast returns (SablierV2ProxyTargetApprove targetApprove) {
        targetApprove = new SablierV2ProxyTargetApprove();
    }
}
