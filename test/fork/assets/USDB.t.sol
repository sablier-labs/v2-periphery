// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { CreateWithTimestamps_LockupDynamic_BatchLockup_Fork_Test } from "../batch-lockup/createWithTimestampsLD.t.sol";
import { CreateWithTimestamps_LockupLinear_BatchLockup_Fork_Test } from "../batch-lockup/createWithTimestampsLL.t.sol";
import { CreateWithTimestamps_LockupTranched_BatchLockup_Fork_Test } from "../batch-lockup/createWithTimestampsLT.t.sol";
import { MerkleLL_Fork_Test } from "../merkle-lockup/MerkleLL.t.sol";
import { MerkleLT_Fork_Test } from "../merkle-lockup/MerkleLT.t.sol";

/// @dev A USD token with rebasing yield deployed on Blast L2.
IERC20 constant usdb = IERC20(0x4300000000000000000000000000000000000003);

contract USDB_CreateWithTimestamps_LockupDynamic_BatchLockup_Fork_Test is
    CreateWithTimestamps_LockupDynamic_BatchLockup_Fork_Test(usdb)
{ }

contract USDB_CreateWithTimestamps_LockupLinear_BatchLockup_Fork_Test is
    CreateWithTimestamps_LockupLinear_BatchLockup_Fork_Test(usdb)
{ }

contract USDB_CreateWithTimestamps_LockupTranched_BatchLockup_Fork_Test is
    CreateWithTimestamps_LockupTranched_BatchLockup_Fork_Test(usdb)
{ }

contract USDB_MerkleLL_Fork_Test is MerkleLL_Fork_Test(usdb) { }

contract USDB_MerkleLT_Fork_Test is MerkleLT_Fork_Test(usdb) { }
