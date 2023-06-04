// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <0.9.0;

import { SablierV2Comptroller } from "@sablier/v2-core/SablierV2Comptroller.sol";
import { SablierV2LockupDynamic } from "@sablier/v2-core/SablierV2LockupDynamic.sol";
import { SablierV2LockupLinear } from "@sablier/v2-core/SablierV2LockupLinear.sol";
import { SablierV2NFTDescriptor } from "@sablier/v2-core/SablierV2NFTDescriptor.sol";
import { BaseScript } from "@sablier/v2-core-script/Base.s.sol";

import { SablierV2Archive } from "../src/SablierV2Archive.sol";
import { SablierV2ProxyPlugin } from "../src/SablierV2ProxyPlugin.sol";
import { SablierV2ProxyTarget } from "../src/SablierV2ProxyTarget.sol";

/// @notice Deploys all Sablier V2 contracts and lists Lockup Dynamic and Lockup Linear in the archive.
contract DeployProtocol is BaseScript {
    function run(
        address admin,
        uint256 maxSegmentCount
    )
        public
        virtual
        returns (
            SablierV2Comptroller comptroller,
            SablierV2LockupDynamic lockupDynamic,
            SablierV2LockupLinear lockupLinear,
            SablierV2NFTDescriptor nftDescriptor,
            SablierV2Archive archive,
            SablierV2ProxyPlugin plugin,
            SablierV2ProxyTarget target
        )
    {
        // Deploy the core contracts.
        comptroller = new SablierV2Comptroller(admin);
        nftDescriptor = new SablierV2NFTDescriptor();
        lockupDynamic = new SablierV2LockupDynamic(admin, comptroller, nftDescriptor, maxSegmentCount);
        lockupLinear = new SablierV2LockupLinear(admin, comptroller, nftDescriptor);

        // Deploy the periphery contracts.
        archive = new SablierV2Archive(address(this));
        plugin = new SablierV2ProxyPlugin(archive);
        target = new SablierV2ProxyTarget();

        // List the core contracts in the archive.
        archive.list(address(lockupDynamic));
        archive.list(address(lockupLinear));
        archive.transferAdmin(admin);
    }
}
