// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { ISablierV2LockupTranched } from "@sablier/v2-core/src/interfaces/ISablierV2LockupTranched.sol";
import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { ISablierV2MerkleLL } from "./interfaces/ISablierV2MerkleLL.sol";
import { ISablierV2MerkleLockupFactory } from "./interfaces/ISablierV2MerkleLockupFactory.sol";
import { ISablierV2MerkleLT } from "./interfaces/ISablierV2MerkleLT.sol";
import { SablierV2MerkleLL } from "./SablierV2MerkleLL.sol";
import { SablierV2MerkleLT } from "./SablierV2MerkleLT.sol";
import { MerkleLockup, MerkleLT } from "./types/DataTypes.sol";

/// @title SablierV2MerkleLockupFactory
/// @notice See the documentation in {ISablierV2MerkleLockupFactory}.
contract SablierV2MerkleLockupFactory is ISablierV2MerkleLockupFactory {
    /*//////////////////////////////////////////////////////////////////////////
                            USER-FACING CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice inheritdoc ISablierV2MerkleLockupFactory
    function computeMerkleLLAddress(
        MerkleLockup.ConstructorParams memory baseParams,
        ISablierV2LockupLinear lockupLinear,
        LockupLinear.Durations memory streamDurations
    )
        external
        view
        returns (address merkleLL)
    {
        // Hash the parameters to generate a salt.
        bytes32 salt = keccak256(
            abi.encodePacked(
                baseParams.asset,
                baseParams.cancelable,
                baseParams.expiration,
                baseParams.initialAdmin,
                abi.encode(baseParams.ipfsCID),
                baseParams.merkleRoot,
                bytes32(abi.encodePacked(baseParams.name)),
                baseParams.transferable,
                lockupLinear,
                abi.encode(streamDurations)
            )
        );

        // Get the constructor argument.
        bytes memory initcode = abi.encode(baseParams, lockupLinear, streamDurations);

        // Compute the CREATE2 address.
        bytes32 merkleLLHash = keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(initcode)));

        return address(uint160(uint256(merkleLLHash)));
    }

    /// @notice inheritdoc ISablierV2MerkleLockupFactory
    function computeMerkleLTAddress(
        MerkleLockup.ConstructorParams memory baseParams,
        ISablierV2LockupTranched lockupTranched,
        MerkleLT.TrancheWithPercentage[] memory tranchesWithPercentages
    )
        external
        view
        returns (address merkleLT)
    {
        // Calculate the sum of percentages and durations across all tranches.
        uint64 totalPercentage;
        uint256 totalDuration;
        for (uint256 i = 0; i < tranchesWithPercentages.length; ++i) {
            uint64 percentage = tranchesWithPercentages[i].unlockPercentage.unwrap();
            totalPercentage = totalPercentage + percentage;
            unchecked {
                // Safe to use `unchecked` because its only used in the event.
                totalDuration += tranchesWithPercentages[i].duration;
            }
        }

        // Hash the parameters to generate a salt.
        bytes32 salt = keccak256(
            abi.encodePacked(
                baseParams.asset,
                baseParams.cancelable,
                baseParams.expiration,
                baseParams.initialAdmin,
                abi.encode(baseParams.ipfsCID),
                baseParams.merkleRoot,
                bytes32(abi.encodePacked(baseParams.name)),
                baseParams.transferable,
                lockupTranched,
                totalPercentage
            )
        );

        // Get the constructor argument.
        bytes memory initcode = abi.encode(baseParams, lockupTranched, tranchesWithPercentages, totalPercentage);

        // Compute the CREATE2 address.
        bytes32 merkleLTHash = keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(initcode)));

        return address(uint160(uint256(merkleLTHash)));
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice inheritdoc ISablierV2MerkleLockupFactory
    function createMerkleLL(
        MerkleLockup.ConstructorParams memory baseParams,
        ISablierV2LockupLinear lockupLinear,
        LockupLinear.Durations memory streamDurations,
        uint256 aggregateAmount,
        uint256 recipientCount
    )
        external
        returns (ISablierV2MerkleLL merkleLL)
    {
        // Hash the parameters to generate a salt.
        bytes32 salt = keccak256(
            abi.encodePacked(
                baseParams.asset,
                baseParams.cancelable,
                baseParams.expiration,
                baseParams.initialAdmin,
                abi.encode(baseParams.ipfsCID),
                baseParams.merkleRoot,
                bytes32(abi.encodePacked(baseParams.name)),
                baseParams.transferable,
                lockupLinear,
                abi.encode(streamDurations)
            )
        );

        // Deploy the MerkleLockup contract with CREATE2.
        merkleLL = new SablierV2MerkleLL{ salt: salt }(baseParams, lockupLinear, streamDurations);

        // Log the creation of the MerkleLockup contract, including some metadata that is not stored on-chain.
        emit CreateMerkleLL(merkleLL, baseParams, lockupLinear, streamDurations, aggregateAmount, recipientCount);
    }

    /// @notice inheritdoc ISablierV2MerkleLockupFactory
    function createMerkleLT(
        MerkleLockup.ConstructorParams memory baseParams,
        ISablierV2LockupTranched lockupTranched,
        MerkleLT.TrancheWithPercentage[] memory tranchesWithPercentages,
        uint256 aggregateAmount,
        uint256 recipientCount
    )
        external
        returns (ISablierV2MerkleLT merkleLT)
    {
        // Calculate the sum of percentages and durations across all tranches.
        uint64 totalPercentage;
        uint256 totalDuration;
        for (uint256 i = 0; i < tranchesWithPercentages.length; ++i) {
            uint64 percentage = tranchesWithPercentages[i].unlockPercentage.unwrap();
            totalPercentage = totalPercentage + percentage;
            unchecked {
                // Safe to use `unchecked` because its only used in the event.
                totalDuration += tranchesWithPercentages[i].duration;
            }
        }

        // Hash the parameters to generate a salt.
        bytes32 salt = keccak256(
            abi.encodePacked(
                baseParams.asset,
                baseParams.cancelable,
                baseParams.expiration,
                baseParams.initialAdmin,
                abi.encode(baseParams.ipfsCID),
                baseParams.merkleRoot,
                bytes32(abi.encodePacked(baseParams.name)),
                baseParams.transferable,
                lockupTranched,
                totalPercentage
            )
        );

        // Deploy the MerkleLockup contract with CREATE2.
        merkleLT =
            new SablierV2MerkleLT{ salt: salt }(baseParams, lockupTranched, tranchesWithPercentages, totalPercentage);

        // Log the creation of the MerkleLockup contract, including some metadata that is not stored on-chain.
        emit CreateMerkleLT(
            merkleLT,
            baseParams,
            lockupTranched,
            tranchesWithPercentages,
            totalDuration,
            aggregateAmount,
            recipientCount
        );
    }
}
