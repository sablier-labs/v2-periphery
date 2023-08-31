// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { AirstreamCampaignLL_Fork_Test } from "../airstream/CampaignLL.t.sol";
import { OnStreamCanceled_Fork_Test } from "../plugin/onStreamCanceled.t.sol";
import {
    BatchCancelMultiple_TargetApprove_Fork_Test,
    BatchCreate_TargetApprove_Fork_Test
} from "../target/TargetApprove.t.sol";
import {
    BatchCancelMultiple_TargetPermit2_Fork_Test,
    BatchCreate_TargetPermit2_Fork_Test
} from "../target/TargetPermit2.t.sol";
import { BatchCancelMultiple_TargetPush_Fork_Test, BatchCreate_TargetPush_Fork_Test } from "../target/TargetPush.t.sol";

IERC20 constant usdt = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);

contract USDT_AirstreamCampaignLL_Fork_Test is AirstreamCampaignLL_Fork_Test(usdt) { }

contract USDT_BatchCancelMultiple_TargetApprove_Fork_Test is BatchCancelMultiple_TargetApprove_Fork_Test(usdt) { }

contract USDT_BatchCancelMultiple_TargetPermit2_Fork_Test is BatchCancelMultiple_TargetPermit2_Fork_Test(usdt) { }

contract USDT_BatchCancelMultiple_TargetPush_Fork_Test is BatchCancelMultiple_TargetPush_Fork_Test(usdt) { }

contract USDT_BatchCreate_TargetApprove_Fork_Test is BatchCreate_TargetApprove_Fork_Test(usdt) { }

contract USDT_BatchCreate_TargetPermit2_Fork_Test is BatchCreate_TargetPermit2_Fork_Test(usdt) { }

contract USDT_BatchCreate_TargetPush_Fork_Test is BatchCreate_TargetPush_Fork_Test(usdt) { }

contract USDT_OnStreamCanceled_Plugin_Fork_Test is OnStreamCanceled_Fork_Test(usdt) { }
