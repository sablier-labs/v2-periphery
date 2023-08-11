// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <0.9.0;

import { SablierV2Comptroller } from "@sablier/v2-core/src/SablierV2Comptroller.sol";
import { SablierV2LockupDynamic } from "@sablier/v2-core/src/SablierV2LockupDynamic.sol";
import { SablierV2LockupLinear } from "@sablier/v2-core/src/SablierV2LockupLinear.sol";
import { SablierV2NFTDescriptor } from "@sablier/v2-core/src/SablierV2NFTDescriptor.sol";
import { BaseScript } from "@sablier/v2-core-script/Base.s.sol";
import { IAllowanceTransfer } from "@uniswap/permit2/interfaces/IAllowanceTransfer.sol";

import { SablierV2Archive } from "../src/SablierV2Archive.sol";
import { SablierV2ProxyPlugin } from "../src/SablierV2ProxyPlugin.sol";
import { SablierV2ProxyTargetApprove } from "../src/SablierV2ProxyTargetApprove.sol";
import { SablierV2ProxyTargetPermit2 } from "../src/SablierV2ProxyTargetPermit2.sol";

/// @notice Deploys the Sablier V2 Protocol and lists the streaming contracts in the archive.
contract DeployProtocol is BaseScript {
    function run(
        address initialAdmin,
        uint256 maxSegmentCount,
        IAllowanceTransfer permit2
    )
        public
        virtual
        broadcast
        returns (
            SablierV2Comptroller comptroller,
            SablierV2LockupDynamic lockupDynamic,
            SablierV2LockupLinear lockupLinear,
            SablierV2NFTDescriptor nftDescriptor,
            SablierV2Archive archive,
            SablierV2ProxyPlugin plugin,
            SablierV2ProxyTargetApprove targetApprove,
            SablierV2ProxyTargetPermit2 targetPermit2
        )
    {
        // Deploy V2 Core.
        comptroller = new SablierV2Comptroller(initialAdmin);
        nftDescriptor = new SablierV2NFTDescriptor();
        lockupDynamic = new SablierV2LockupDynamic(initialAdmin, comptroller, nftDescriptor, maxSegmentCount);
        lockupLinear = new SablierV2LockupLinear(initialAdmin, comptroller, nftDescriptor);

        // Deploy V2 Periphery.
        archive = new SablierV2Archive(initialAdmin);
        plugin = new SablierV2ProxyPlugin(archive);
        targetApprove = new SablierV2ProxyTargetApprove();
        targetPermit2 = new SablierV2ProxyTargetPermit2(permit2);

        // List the streaming contracts.
        archive.list(address(lockupDynamic));
        archive.list(address(lockupLinear));
    }
}
