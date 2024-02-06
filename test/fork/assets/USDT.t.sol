// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { CreateWithTimestamps_LockupDynamic_Batch_Fork_Test } from "../batch/createWithTimestampsLD.t.sol";
import { CreateWithTimestamps_LockupLinear_Batch_Fork_Test } from "../batch/createWithTimestampsLL.t.sol";
import { MerkleLockupLD_Fork_Test } from "../merkle-lockup/MerkleLockupLD.t.sol";
import { MerkleLockupLL_Fork_Test } from "../merkle-lockup/MerkleLockupLL.t.sol";

/// @dev An ERC-20 asset that suffers from the missing return value bug.
IERC20 constant usdt = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);

contract USDT_CreateWithTimestamps_LockupDynamic_Batch_Fork_Test is
    CreateWithTimestamps_LockupDynamic_Batch_Fork_Test(usdt)
{ }

contract USDT_CreateWithTimestamps_LockupLinear_Batch_Fork_Test is
    CreateWithTimestamps_LockupLinear_Batch_Fork_Test(usdt)
{ }

contract USDT_MerkleLockupLD_Fork_Test is MerkleLockupLD_Fork_Test(usdt) { }

contract USDT_MerkleLockupLL_Fork_Test is MerkleLockupLL_Fork_Test(usdt) { }
