// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";

import { BatchCreate_Fork_Test } from "../batch/batchCreate.t.sol";

IERC20 constant asset = IERC20(0x509Ee0d083DdF8AC028f2a56731412edD63223B9);

contract USDT_Fork_Test is BatchCreate_Fork_Test(asset) { }
