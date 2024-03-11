// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { CreateWithTimestamps_LockupDynamic_Batch_Fork_Test } from "../batch/createWithTimestampsLD.t.sol";
import { CreateWithTimestamps_LockupLinear_Batch_Fork_Test } from "../batch/createWithTimestampsLL.t.sol";
import { CreateWithTimestamps_LockupTranched_Batch_Fork_Test } from "../batch/createWithTimestampsLT.t.sol";
import { MerkleLockupLL_Fork_Test } from "../merkle-lockup/MerkleLockupLL.t.sol";
import { MerkleLockupLT_Fork_Test } from "../merkle-lockup/MerkleLockupLT.t.sol";

/// @dev An ERC-20 asset with 6 decimals.
IERC20 constant usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

contract USDC_CreateWithTimestamps_LockupDynamic_Batch_Fork_Test is
    CreateWithTimestamps_LockupDynamic_Batch_Fork_Test(usdc)
{ }

contract USDC_CreateWithTimestamps_LockupLinear_Batch_Fork_Test is
    CreateWithTimestamps_LockupLinear_Batch_Fork_Test(usdc)
{ }

contract USDC_CreateWithTimestamps_LockupTranched_Batch_Fork_Test is
    CreateWithTimestamps_LockupTranched_Batch_Fork_Test(usdc)
{ }

contract USDC_MerkleLockupLL_Fork_Test is MerkleLockupLL_Fork_Test(usdc) { }

contract USDC_MerkleLockupLT_Fork_Test is MerkleLockupLT_Fork_Test(usdc) { }
