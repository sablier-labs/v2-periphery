// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.18 <0.9.0;

import { Script } from "forge-std/Script.sol";

import { SablierV2ProxyTarget } from "src/SablierV2ProxyTarget.sol";

import { BaseScript } from "@sablier/v2-core/../script/shared/Base.s.sol";

contract DeploySablierV2ProxyTarget is Script, BaseScript {
    function run() public broadcaster returns (SablierV2ProxyTarget batch) {
        batch = new SablierV2ProxyTarget();
    }
}
