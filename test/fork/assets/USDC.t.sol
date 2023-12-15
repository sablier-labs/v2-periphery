// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { CreateWithMilestones_Batch_Fork_Test } from "../batch/createWithMilestones.t.sol";
import { CreateWithRange_Batch_Fork_Test } from "../batch/createWithRange.t.sol";
import { MerkleStreamerLL_Fork_Test } from "../merkle-streamer/MerkleStreamerLL.t.sol";

IERC20 constant usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

contract USDC_CreateWithMilestones_Batch_Fork_Test is CreateWithMilestones_Batch_Fork_Test(usdc) { }

contract USDC_CreateWithRange_Batch_Fork_Test is CreateWithRange_Batch_Fork_Test(usdc) { }

contract USDC_MerkleStreamerLL_Fork_Test is MerkleStreamerLL_Fork_Test(usdc) { }
