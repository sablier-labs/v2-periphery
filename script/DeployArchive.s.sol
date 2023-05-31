// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <0.9.0;

import { BaseScript } from "@sablier/v2-core-script/Base.s.sol";

import { SablierV2Archive } from "../src/SablierV2Archive.sol";

contract DeployArchive is BaseScript {
    function run(address initialAdmin) public broadcaster returns (SablierV2Archive archive) {
        archive = new SablierV2Archive(initialAdmin);
    }
}
