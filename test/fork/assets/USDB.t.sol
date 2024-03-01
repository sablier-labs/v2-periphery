// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { CreateWithTimestamps_LockupDynamic_Batch_Fork_Test } from "../batch/createWithTimestampsLD.t.sol";
import { CreateWithTimestamps_LockupLinear_Batch_Fork_Test } from "../batch/createWithTimestampsLL.t.sol";
import { CreateWithTimestamps_LockupTranched_Batch_Fork_Test } from "../batch/createWithTimestampsLT.t.sol";
import { MerkleLockupLL_Fork_Test } from "../merkle-lockup/MerkleLockupLL.t.sol";
import { MerkleLockupLT_Fork_Test } from "../merkle-lockup/MerkleLockupLT.t.sol";

/// @dev A USD token with rebasing yield deployed on Blast L2.
IERC20 constant usdb = IERC20(0x4300000000000000000000000000000000000003);

contract USDB_CreateWithTimestamps_LockupDynamic_Batch_Fork_Test is
    CreateWithTimestamps_LockupDynamic_Batch_Fork_Test(usdb)
{ }

contract USDB_CreateWithTimestamps_LockupLinear_Batch_Fork_Test is
    CreateWithTimestamps_LockupLinear_Batch_Fork_Test(usdb)
{ }

contract USDB_CreateWithTimestamps_LockupTranched_Batch_Fork_Test is
    CreateWithTimestamps_LockupTranched_Batch_Fork_Test(usdb)
{ }

contract USDB_MerkleLockupLL_Fork_Test is MerkleLockupLL_Fork_Test(usdb) { }

contract USDB_MerkleLockupLT_Fork_Test is MerkleLockupLT_Fork_Test(usdb) { }
