// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { OnStreamCanceled_Fork_Test } from "../plugin/on-stream-canceled/onStreamCanceled.t.sol";
import { BatchCreate_Fork_Test } from "../target/batch/batchCreate.t.sol";

IERC20 constant asset = IERC20(0x509Ee0d083DdF8AC028f2a56731412edD63223B9);

contract USDT_Target_Fork_Test is BatchCreate_Fork_Test(asset) { }

contract USDT_Plugin_Fork_Test is OnStreamCanceled_Fork_Test(asset) { }
