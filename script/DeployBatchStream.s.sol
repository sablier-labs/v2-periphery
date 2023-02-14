// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.18 <0.9.0;

import { Script } from "forge-std/Script.sol";

import { BatchStream } from "src/BatchStream.sol";

import { Base_Script } from "./helpers/Base.s.sol";

contract DeployBatchStream is Script, Base_Script {
    function run() public broadcaster returns (BatchStream batch) {
        batch = new BatchStream();
    }
}
