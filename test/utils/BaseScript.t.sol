// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { PRBTest } from "@prb/test/src/PRBTest.sol";

import { BaseScript } from "script/Base.s.sol";

contract BaseScript_Test is PRBTest {
    using Strings for uint256;

    BaseScript internal baseScript = new BaseScript();

    function test_ConstructCreate2Salt() public {
        string memory chainId = block.chainid.toString();
        string memory version = "1.1.1";
        string memory salt = string.concat("ChainID ", chainId, ", Version ", version);

        bytes32 actualSalt = baseScript.constructCreate2Salt();
        bytes32 expectedSalt = bytes32(abi.encodePacked(salt));
        assertEq(actualSalt, expectedSalt, "CREATE2 salt mismatch");
    }
}
