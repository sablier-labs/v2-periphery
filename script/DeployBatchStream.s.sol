// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";
import { ISablierV2LockupPro } from "@sablier/v2-core/interfaces/ISablierV2LockupPro.sol";
import { Common } from "core-scripts/Helpers/Common.s.sol";
import { Script } from "forge-std/Script.sol";

import { BatchStream } from "src/BatchStream.sol";

contract DeployBatchStream is Script, Common {
    function run(
        ISablierV2LockupLinear linear,
        ISablierV2LockupPro pro
    ) public broadcaster returns (BatchStream batch) {
        batch = new BatchStream(linear, pro);
    }
}
