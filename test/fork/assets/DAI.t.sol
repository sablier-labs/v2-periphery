// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";

import { BatchCreate_Fork_Test } from "../batch/batchCreate.t.sol";

IERC20 constant asset = IERC20(0x11fE4B6AE13d2a6055C8D9cF65c55bac32B5d844);

contract DAI_Fork_Test is BatchCreate_Fork_Test(asset) { }
