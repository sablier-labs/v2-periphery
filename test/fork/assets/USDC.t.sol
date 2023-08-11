// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { OnStreamCanceled_Fork_Test } from "../plugin/onStreamCanceled.t.sol";
import {
    BatchCancelMultiple_TargetApprove_Fork_Test,
    BatchCreate_TargetApprove_Fork_Test
} from "../target/TargetApprove.t.sol";
import {
    BatchCancelMultiple_TargetPermit2_Fork_Test,
    BatchCreate_TargetPermit2_Fork_Test
} from "../target/TargetPermit2.t.sol";

IERC20 constant usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

contract USDC_BatchCancelMultiple_TargetApprove_Fork_Test is BatchCancelMultiple_TargetApprove_Fork_Test(usdc) { }

contract USDC_BatchCancelMultiple_TargetPermit2_Fork_Test is BatchCancelMultiple_TargetPermit2_Fork_Test(usdc) { }

contract USDC_BatchCreate_TargetApprove_Fork_Test is BatchCreate_TargetApprove_Fork_Test(usdc) { }

contract USDC_BatchCreate_TargetPermit2_Fork_Test is BatchCreate_TargetPermit2_Fork_Test(usdc) { }

contract USDC_OnStreamCanceled_Plugin_Fork_Test is OnStreamCanceled_Fork_Test(usdc) { }
