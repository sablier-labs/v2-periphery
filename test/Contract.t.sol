// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { Test } from "forge-std/Test.sol";

import { Contract } from "src/Contract.sol";

contract TestContract is Test {
    Contract internal c;

    function setUp() public {
        c = new Contract();
    }

    function testFoo() public {
        assertEq(c.foo(1), 1);
    }

    function testFooFuzz(uint256 a) public {
        vm.assume(a < type(uint256).max);
        assertEq(c.foo(a), a);
    }
}
