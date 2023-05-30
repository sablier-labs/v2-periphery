// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { OnStreamCanceled_Fork_Test } from "../plugin/on-stream-canceled/onStreamCanceled.t.sol";
import { BatchCreate_Fork_Test } from "../target/batch/batchCreate.t.sol";

IERC20 constant asset = IERC20(0x11fE4B6AE13d2a6055C8D9cF65c55bac32B5d844);

contract DAI_Target_Fork_Test is BatchCreate_Fork_Test(asset) { }

contract DAI_Plugin_Fork_Test is OnStreamCanceled_Fork_Test(asset) { }
