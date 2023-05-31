// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <0.9.0;

import { BaseScript } from "@sablier/v2-core-script/Base.s.sol";

import { ISablierV2Archive } from "../src/interfaces/ISablierV2Archive.sol";

contract ListInArchive is BaseScript {
    function run(ISablierV2Archive archive, address addr) public broadcaster {
        archive.list(addr);
    }
}
