// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <0.9.0;

import { BaseScript } from "@sablier/v2-core-script/Base.s.sol";
import { IAllowanceTransfer } from "@uniswap/permit2/interfaces/IAllowanceTransfer.sol";

import { SablierV2ProxyTargetPermit2 } from "../src/SablierV2ProxyTargetPermit2.sol";

contract DeployProxyTargetPermit2 is BaseScript {
    function run(IAllowanceTransfer permit2) public broadcast returns (SablierV2ProxyTargetPermit2 targetPermit2) {
        targetPermit2 = new SablierV2ProxyTargetPermit2(permit2);
    }
}
