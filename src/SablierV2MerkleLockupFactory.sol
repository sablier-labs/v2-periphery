// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";

import { SablierV2MerkleLockupLL } from "./SablierV2MerkleLockupLL.sol";
import { ISablierV2MerkleLockupFactory } from "./interfaces/ISablierV2MerkleLockupFactory.sol";
import { ISablierV2MerkleLockupLL } from "./interfaces/ISablierV2MerkleLockupLL.sol";
import { MerkleLockup } from "./types/DataTypes.sol";

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
}
