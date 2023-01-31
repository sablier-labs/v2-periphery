// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.13 <0.9.0;

import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";
import { ISablierV2LockupPro } from "@sablier/v2-core/interfaces/ISablierV2LockupPro.sol";
import { Script } from "forge-std/Script.sol";

import { BatchStream } from "src/BatchStream.sol";

import { Common } from "./helpers/Common.s.sol";

contract DeployBatchStream is Script, Common {
    function run(
        ISablierV2LockupLinear linear,
        ISablierV2LockupPro pro
    ) public broadcaster returns (BatchStream batch) {
        batch = new BatchStream(linear, pro);
    }
}
