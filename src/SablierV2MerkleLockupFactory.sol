// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { UD60x18, ud } from "@prb/math/src/UD60x18.sol";
import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";
import { ISablierV2LockupTranched } from "@sablier/v2-core/src/interfaces/ISablierV2LockupTranched.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";

import { SablierV2MerkleLockupLL } from "./SablierV2MerkleLockupLL.sol";
import { SablierV2MerkleLockupLT } from "./SablierV2MerkleLockupLT.sol";
import { ISablierV2MerkleLockupFactory } from "./interfaces/ISablierV2MerkleLockupFactory.sol";
import { ISablierV2MerkleLockupLL } from "./interfaces/ISablierV2MerkleLockupLL.sol";
import { ISablierV2MerkleLockupLT } from "./interfaces/ISablierV2MerkleLockupLT.sol";
import { Errors } from "./libraries/Errors.sol";
import { MerkleLockup, MerkleLockupLT } from "./types/DataTypes.sol";

/// @title SablierV2MerkleLockupFactory
/// @notice See the documentation in {ISablierV2MerkleLockupFactory}.
contract SablierV2MerkleLockupFactory is ISablierV2MerkleLockupFactory {
    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice inheritdoc ISablierV2MerkleLockupFactory
    function createMerkleLockupLL(
        MerkleLockup.ConstructorParams memory baseParams,
        ISablierV2LockupLinear lockupLinear,
        LockupLinear.Durations memory streamDurations,
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
                abi.encode(baseParams.ipfsCID),
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

        // Log the creation of the Merkle Lockup, including some metadata that is not stored on-chain.
        emit CreateMerkleLockupLL(
            merkleLockupLL, baseParams, lockupLinear, streamDurations, aggregateAmount, recipientsCount
        );
    }

    /// @notice inheritdoc ISablierV2MerkleLockupFactory
    function createMerkleLockupLT(
        MerkleLockup.ConstructorParams memory baseParams,
        ISablierV2LockupTranched lockupTranched,
        MerkleLockupLT.TrancheWithPercentage[] memory tranchesWithPercentages,
        uint256 aggregateAmount,
        uint256 recipientsCount
    )
        external
        returns (ISablierV2MerkleLockupLT merkleLockupLT)
    {
        // Calculate the sum of percentages across all tranches.
        UD60x18 percentagesSum;
        uint256 trancheCount = tranchesWithPercentages.length;
        for (uint256 i = 0; i < trancheCount; ++i) {
            UD60x18 percentage = (tranchesWithPercentages[i].amountPercentage).intoUD60x18();
            percentagesSum = percentagesSum.add(percentage);
        }

        // Checks: the sum percentage equal 100%.
        if (!percentagesSum.eq(ud(1e18))) {
            revert Errors.SablierV2MerkleLockupFactory_PercentageSumNotEqualOneHundred();
        }

        // Hash the parameters to generate a salt.
        bytes32 salt = keccak256(
            abi.encodePacked(
                baseParams.initialAdmin,
                baseParams.asset,
                abi.encode(baseParams.ipfsCID),
                bytes32(abi.encodePacked(baseParams.name)),
                baseParams.merkleRoot,
                baseParams.expiration,
                baseParams.cancelable,
                baseParams.transferable,
                lockupTranched,
                abi.encode(tranchesWithPercentages)
            )
        );

        // Deploy the Merkle Lockup contract with CREATE2.
        merkleLockupLT = new SablierV2MerkleLockupLT{ salt: salt }(baseParams, lockupTranched, tranchesWithPercentages);

        // Log the creation of the Merkle Lockup, including some metadata that is not stored on-chain.
        emit CreateMerkleLockupLT(
            merkleLockupLT, baseParams, lockupTranched, tranchesWithPercentages, aggregateAmount, recipientsCount
        );
    }
}
