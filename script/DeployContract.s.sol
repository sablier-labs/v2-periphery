// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { Script } from "forge-std/Script.sol";

import { Contract } from "src/Contract.sol";

contract DeployContract is Script {
    function run() public returns (Contract c) {
        vm.startBroadcast();
        c = new Contract();
        vm.stopBroadcast();
    }
}
