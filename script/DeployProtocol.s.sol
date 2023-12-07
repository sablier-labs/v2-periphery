// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <0.9.0;

import { SablierV2Comptroller } from "@sablier/v2-core/src/SablierV2Comptroller.sol";
import { SablierV2LockupDynamic } from "@sablier/v2-core/src/SablierV2LockupDynamic.sol";
import { SablierV2LockupLinear } from "@sablier/v2-core/src/SablierV2LockupLinear.sol";
import { SablierV2NFTDescriptor } from "@sablier/v2-core/src/SablierV2NFTDescriptor.sol";
import { BaseScript } from "./Base.s.sol";

import { SablierV2MerkleStreamerFactory } from "../src/SablierV2MerkleStreamerFactory.sol";
import { SablierV2Batch } from "../src/SablierV2Batch.sol";

/// @notice Deploys the Sablier V2 Protocol.
contract DeployProtocol is BaseScript {
    function run(
        address initialAdmin,
        uint256 maxSegmentCount
    )
        public
        virtual
        broadcast
        returns (
            SablierV2Comptroller comptroller,
            SablierV2LockupDynamic lockupDynamic,
            SablierV2LockupLinear lockupLinear,
            SablierV2NFTDescriptor nftDescriptor,
            SablierV2Batch batch,
            SablierV2MerkleStreamerFactory merkleStreamerFactory
        )
    {
        // Deploy V2 Core.
        comptroller = new SablierV2Comptroller(initialAdmin);
        nftDescriptor = new SablierV2NFTDescriptor();
        lockupDynamic = new SablierV2LockupDynamic(initialAdmin, comptroller, nftDescriptor, maxSegmentCount);
        lockupLinear = new SablierV2LockupLinear(initialAdmin, comptroller, nftDescriptor);

        batch = new SablierV2Batch();
        merkleStreamerFactory = new SablierV2MerkleStreamerFactory();
    }
}
