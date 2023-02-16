// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.18 <0.9.0;

import { Script } from "forge-std/Script.sol";

import { SablierV2ProxyTarget } from "src/SablierV2ProxyTarget.sol";

import { Base_Script } from "./helpers/Base.s.sol";

contract DeploySablierV2ProxyTarget is Script, Base_Script {
    function run() public broadcaster returns (SablierV2ProxyTarget batch) {
        batch = new SablierV2ProxyTarget();
    }
}
