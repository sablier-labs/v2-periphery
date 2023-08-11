// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { ISablierV2ProxyTarget } from "src/interfaces/ISablierV2ProxyTarget.sol";

import { Fork_Test } from "../Fork.t.sol";
import { BatchCancelMultiple_Fork_Test } from "./batchCancelMultiple.t.sol";
import { BatchCreate_Fork_Test } from "./batchCreate.t.sol";
import { WrapAndCreate_Fork_Test } from "./wrapAndCreate.t.sol";

abstract contract TargetPermit2_Fork_Test is Fork_Test {
    function setUp() public virtual override {
        Fork_Test.setUp();
        target = ISablierV2ProxyTarget(targetPermit2);
    }
}

/// @dev Inherited by the asset contracts in "test/fork/assets"
abstract contract BatchCancelMultiple_TargetPermit2_Fork_Test is
    TargetPermit2_Fork_Test,
    BatchCancelMultiple_Fork_Test
{
    constructor(IERC20 asset_) BatchCancelMultiple_Fork_Test(asset_) { }

    function setUp() public virtual override(TargetPermit2_Fork_Test, BatchCancelMultiple_Fork_Test) {
        TargetPermit2_Fork_Test.setUp();
        BatchCancelMultiple_Fork_Test.setUp();
    }
}

/// @dev Inherited by the asset contracts in "test/fork/assets"
abstract contract BatchCreate_TargetPermit2_Fork_Test is TargetPermit2_Fork_Test, BatchCreate_Fork_Test {
    constructor(IERC20 asset_) BatchCreate_Fork_Test(asset_) { }

    function setUp() public virtual override(TargetPermit2_Fork_Test, BatchCreate_Fork_Test) {
        TargetPermit2_Fork_Test.setUp();
        BatchCreate_Fork_Test.setUp();
    }
}

contract WrapAndCreate_TargetPermit2_Fork_Test is TargetPermit2_Fork_Test, WrapAndCreate_Fork_Test {
    function setUp() public virtual override(TargetPermit2_Fork_Test, WrapAndCreate_Fork_Test) {
        TargetPermit2_Fork_Test.setUp();
        WrapAndCreate_Fork_Test.setUp();
    }
}
