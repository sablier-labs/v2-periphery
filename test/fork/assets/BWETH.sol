// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { CreateWithMilestones_Batch_Fork_Test } from "../batch/createWithMilestones.t.sol";
import { CreateWithRange_Batch_Fork_Test } from "../batch/createWithRange.t.sol";
import { MerkleStreamerLL_Fork_Test } from "../merkle-streamer/MerkleStreamerLL.t.sol";

/// @dev A WETH token with rebasing yield deployed on Blast L2.
IERC20 constant bweth = IERC20(0x4200000000000000000000000000000000000023);

contract BWETH_CreateWithMilestones_Batch_Fork_Test is CreateWithMilestones_Batch_Fork_Test(bweth) { }

contract BWETH_CreateWithRange_Batch_Fork_Test is CreateWithRange_Batch_Fork_Test(bweth) { }

contract BWETH_MerkleStreamerLL_Fork_Test is MerkleStreamerLL_Fork_Test(bweth) { }
