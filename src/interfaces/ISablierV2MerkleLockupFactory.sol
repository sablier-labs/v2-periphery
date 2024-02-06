// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { ISablierV2LockupDynamic } from "@sablier/v2-core/src/interfaces/ISablierV2LockupDynamic.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { ISablierV2MerkleLockupLD } from "./ISablierV2MerkleLockupLD.sol";
import { ISablierV2MerkleLockupLL } from "./ISablierV2MerkleLockupLL.sol";
import { MerkleLockup } from "../types/DataTypes.sol";

/// @title ISablierV2MerkleLockupFactory
/// @notice Deploys new airstream campaigns via CREATE2.
interface ISablierV2MerkleLockupFactory {
    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a Sablier V2 Lockup Dynamic Merkle Lockup is created.
    /// @param merkleLockupLD The address of the newly created Merkle Lockup Dynamic contract.
    /// @param baseParams Struct encapsulating the {SablierV2MerkleLockup} parameters, which are documented in
    /// {DataTypes}.
    /// @param lockupDynamic The address of the {SablierV2LockupDynamic} contract.
    /// @param ipfsCID Metadata parameter emitted for indexing purposes.
    /// @param aggregateAmount Total amount of ERC-20 assets to be streamed to all recipients.
    /// @param recipientsCount Total number of recipients eligible to claim.
    event CreateMerkleLockupLD(
        ISablierV2MerkleLockupLD indexed merkleLockupLD,
        MerkleLockup.ConstructorParams indexed baseParams,
        ISablierV2LockupDynamic lockupDynamic,
        string ipfsCID,
        uint256 aggregateAmount,
        uint256 recipientsCount
    );

    /// @notice Emitted when a Sablier V2 Lockup Linear Merkle Lockup is created.
    /// @param merkleLockupLL The address of the newly created Merkle Lockup Dynamic contract.
    /// @param baseParams Struct encapsulating the {SablierV2MerkleLockup} parameters, which are documented in
    /// {DataTypes}.
    /// @param lockupLinear The address of the {SablierV2LockupLinear} contract.
    /// @param streamDurations The durations for each stream due to the recipient.
    /// @param ipfsCID Metadata parameter emitted for indexing purposes.
    /// @param aggregateAmount Total amount of ERC-20 assets to be streamed to all recipients.
    /// @param recipientsCount Total number of recipients eligible to claim.
    event CreateMerkleLockupLL(
        ISablierV2MerkleLockupLL indexed merkleLockupLL,
        MerkleLockup.ConstructorParams indexed baseParams,
        ISablierV2LockupLinear lockupLinear,
        LockupLinear.Durations streamDurations,
        string ipfsCID,
        uint256 aggregateAmount,
        uint256 recipientsCount
    );

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Creates a new Merkle Lockup that uses Lockup Dynamic.
    /// @dev Emits a {CreateMerkleLockupLD} event.
    /// @param baseParams Struct encapsulating the {SablierV2MerkleLockup} parameters, which are documented in
    /// {DataTypes}.
    /// @param lockupDynamic The address of the {SablierV2LockupDynamic} contract.
    /// @param ipfsCID Metadata parameter emitted for indexing purposes.
    /// @param aggregateAmount Total amount of ERC-20 assets to be streamed to all recipients.
    /// @param recipientsCount Total number of recipients eligible to claim.
    /// @return merkleLockupLD The address of the newly created Merkle Lockup Dynamic contract.
    function createMerkleLockupLD(
        MerkleLockup.ConstructorParams memory baseParams,
        ISablierV2LockupDynamic lockupDynamic,
        string memory ipfsCID,
        uint256 aggregateAmount,
        uint256 recipientsCount
    )
        external
        returns (ISablierV2MerkleLockupLD merkleLockupLD);

    /// @notice Creates a new Merkle Lockup that uses Lockup Linear.
    /// @dev Emits a {CreateMerkleLockupLL} event.
    /// @param baseParams Struct encapsulating the {SablierV2MerkleLockup} parameters, which are documented in
    /// {DataTypes}.
    /// @param lockupLinear The address of the {SablierV2LockupLinear} contract.
    /// @param streamDurations The durations for each stream due to the recipient.
    /// @param ipfsCID Metadata parameter emitted for indexing purposes.
    /// @param aggregateAmount Total amount of ERC-20 assets to be streamed to all recipients.
    /// @param recipientsCount Total number of recipients eligible to claim.
    /// @return merkleLockupLL The address of the newly created Merkle Lockup Linear contract.
    function createMerkleLockupLL(
        MerkleLockup.ConstructorParams memory baseParams,
        ISablierV2LockupLinear lockupLinear,
        LockupLinear.Durations memory streamDurations,
        string memory ipfsCID,
        uint256 aggregateAmount,
        uint256 recipientsCount
    )
        external
        returns (ISablierV2MerkleLockupLL merkleLockupLL);
}
