// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";
import { ISablierV2LockupDynamic } from "@sablier/v2-core/src/interfaces/ISablierV2LockupDynamic.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";

import { SablierV2MerkleLockupLD } from "./SablierV2MerkleLockupLD.sol";
import { SablierV2MerkleLockupLL } from "./SablierV2MerkleLockupLL.sol";
import { ISablierV2MerkleLockupFactory } from "./interfaces/ISablierV2MerkleLockupFactory.sol";
import { ISablierV2MerkleLockupLD } from "./interfaces/ISablierV2MerkleLockupLD.sol";
import { ISablierV2MerkleLockupLL } from "./interfaces/ISablierV2MerkleLockupLL.sol";
import { MerkleLockup } from "./types/DataTypes.sol";

/// @title SablierV2MerkleLockupFactory
/// @notice See the documentation in {ISablierV2MerkleLockupFactory}.
contract SablierV2MerkleLockupFactory is ISablierV2MerkleLockupFactory {
    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice inheritdoc ISablierV2MerkleLockupFactory
    function createMerkleLockupLD(
        MerkleLockup.ConstructorParams memory baseParams,
        ISablierV2LockupDynamic lockupDynamic,
        string memory ipfsCID,
        uint256 aggregateAmount,
        uint256 recipientsCount
    )
        external
        returns (ISablierV2MerkleLockupLD merkleLockupLD)
    {
        // Hash the parameters to generate a salt.
        bytes32 salt = keccak256(
            abi.encodePacked(
                baseParams.initialAdmin,
                baseParams.asset,
                bytes32(abi.encodePacked(baseParams.name)),
                baseParams.merkleRoot,
                baseParams.expiration,
                baseParams.cancelable,
                baseParams.transferable,
                lockupDynamic
            )
        );

        // Deploy the Merkle Lockup contract with CREATE2.
        merkleLockupLD = new SablierV2MerkleLockupLD{ salt: salt }(baseParams, lockupDynamic);

        // Using a different function to emit the event to avoid stack too deep error.
        emit CreateMerkleLockupLD(merkleLockupLD, baseParams, lockupDynamic, ipfsCID, aggregateAmount, recipientsCount);
    }

    /// @notice inheritdoc ISablierV2MerkleLockupFactory
    function createMerkleLockupLL(
        MerkleLockup.ConstructorParams memory baseParams,
        ISablierV2LockupLinear lockupLinear,
        LockupLinear.Durations memory streamDurations,
        string memory ipfsCID,
        uint256 aggregateAmount,
        uint256 recipientsCount
    )
        external
        returns (ISablierV2MerkleLockupLL merkleLockupLL)
    {
        // Hash the parameters to generate a salt.
        bytes32 salt = keccak256(
            abi.encodePacked(
                baseParams.initialAdmin,
                baseParams.asset,
                bytes32(abi.encodePacked(baseParams.name)),
                baseParams.merkleRoot,
                baseParams.expiration,
                baseParams.cancelable,
                baseParams.transferable,
                lockupLinear,
                abi.encode(streamDurations)
            )
        );

        // Deploy the Merkle Lockup contract with CREATE2.
        merkleLockupLL = new SablierV2MerkleLockupLL{ salt: salt }(baseParams, lockupLinear, streamDurations);

        // Using a different function to emit the event to avoid stack too deep error.
        emit CreateMerkleLockupLL(
            merkleLockupLL, baseParams, lockupLinear, streamDurations, ipfsCID, aggregateAmount, recipientsCount
        );
    }
}
