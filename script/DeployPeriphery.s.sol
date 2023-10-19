// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <0.9.0;

import { BaseScript } from "@sablier/v2-core-script/Base.s.sol";
import { IAllowanceTransfer } from "@uniswap/permit2/interfaces/IAllowanceTransfer.sol";

import { SablierV2MerkleStreamerFactory } from "../src/SablierV2MerkleStreamerFactory.sol";
import { SablierV2Batch } from "../src/SablierV2Batch.sol";
import { SablierV2ProxyTargetApprove } from "../src/SablierV2ProxyTargetApprove.sol";
import { SablierV2ProxyTargetPermit2 } from "../src/SablierV2ProxyTargetPermit2.sol";
import { SablierV2ProxyTargetPush } from "../src/SablierV2ProxyTargetPush.sol";

/// @notice Deploys all V2 Periphery contract in the following order:
///
/// 1. {SablierV2Batch}
/// 2. {SablierV2MerkleStreamerFactory}
/// 3. {SablierV2ProxyTargetApprove}
/// 4. {SablierV2ProxyTargetPermit2}
/// 5. {SablierV2ProxyTargetPush}
contract DeployPeriphery is BaseScript {
    function run(IAllowanceTransfer permit2)
        public
        broadcast
        returns (
            SablierV2Batch batch,
            SablierV2MerkleStreamerFactory merkleStreamerFactory,
            SablierV2ProxyTargetApprove targetApprove,
            SablierV2ProxyTargetPermit2 targetPermit2,
            SablierV2ProxyTargetPush targetPush
        )
    {
        batch = new SablierV2Batch();
        merkleStreamerFactory = new SablierV2MerkleStreamerFactory();
        targetApprove = new SablierV2ProxyTargetApprove();
        targetPermit2 = new SablierV2ProxyTargetPermit2(permit2);
        targetPush = new SablierV2ProxyTargetPush();
    }
}
