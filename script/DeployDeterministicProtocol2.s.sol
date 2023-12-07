// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <0.9.0;

import { SablierV2Comptroller } from "@sablier/v2-core/src/SablierV2Comptroller.sol";
import { SablierV2LockupDynamic } from "@sablier/v2-core/src/SablierV2LockupDynamic.sol";
import { SablierV2LockupLinear } from "@sablier/v2-core/src/SablierV2LockupLinear.sol";
import { SablierV2NFTDescriptor } from "@sablier/v2-core/src/SablierV2NFTDescriptor.sol";

import { BaseScript } from "./Base.s.sol";

import { SablierV2Batch } from "../src/SablierV2Batch.sol";
import { SablierV2MerkleStreamerFactory } from "../src/SablierV2MerkleStreamerFactory.sol";

/// @notice Deploys the Sablier V2 Protocol deterministically expect for comptroller.
contract DeployDeterministicPeriphery is BaseScript {
    /// @dev The presence of the salt instructs Forge to deploy the contract via a deterministic CREATE2 factory.
    /// https://github.com/Arachnid/deterministic-deployment-proxy
    function run(
        string memory create2Salt,
        address initialAdmin,
        SablierV2Comptroller comptroller
    )
        public
        virtual
        broadcast
        returns (
            SablierV2LockupDynamic lockupDynamic,
            SablierV2LockupLinear lockupLinear,
            SablierV2NFTDescriptor nftDescriptor,
            SablierV2Batch batch,
            SablierV2MerkleStreamerFactory merkleStreamerFactory
        )
    {
        bytes32 salt = bytes32(abi.encodePacked(create2Salt));

        nftDescriptor = new SablierV2NFTDescriptor{ salt: salt }();
        lockupLinear = new SablierV2LockupLinear{ salt: salt }(initialAdmin, comptroller, nftDescriptor);

        uint256 maxSegmentCount = 300;

        lockupDynamic =
            new SablierV2LockupDynamic{ salt: salt }(initialAdmin, comptroller, nftDescriptor, maxSegmentCount);

        batch = new SablierV2Batch{ salt: salt }();
        merkleStreamerFactory = new SablierV2MerkleStreamerFactory{ salt: salt }();
    }
}
