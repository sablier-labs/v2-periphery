// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { ISablierV2LockupTranched } from "@sablier/v2-core/src/interfaces/ISablierV2LockupTranched.sol";
import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { ISablierV2MerkleLockupLL } from "./ISablierV2MerkleLockupLL.sol";
import { ISablierV2MerkleLockupLT } from "./ISablierV2MerkleLockupLT.sol";
import { MerkleLockup, MerkleLockupLT } from "../types/DataTypes.sol";

/// @title ISablierV2MerkleLockupFactory
/// @notice Deploys new Lockup Linear Merkle lockups via CREATE2.
interface ISablierV2MerkleLockupFactory {
    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a {SablierV2MerkleLockupLL} campaign is created.
    event CreateMerkleLockupLL(
        ISablierV2MerkleLockupLL indexed merkleLockupLL,
        MerkleLockup.ConstructorParams baseParams,
        ISablierV2LockupLinear lockupLinear,
        LockupLinear.Durations streamDurations,
        uint256 aggregateAmount,
        uint256 recipientCount
    );

    /// @notice Emitted when a {SablierV2MerkleLockupLT} campaign is created.
    event CreateMerkleLockupLT(
        ISablierV2MerkleLockupLT indexed merkleLockupLT,
        MerkleLockup.ConstructorParams baseParams,
        ISablierV2LockupTranched lockupTranched,
        MerkleLockupLT.TrancheWithPercentage[] tranchesWithPercentages,
        uint256 totalDuration,
        uint256 aggregateAmount,
        uint256 recipientCount
    );

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Creates a new MerkleLockup campaign with a Lockup Linear distribution.
    /// @dev Emits a {CreateMerkleLockupLL} event.
    /// @param baseParams Struct encapsulating the {SablierV2MerkleLockup} parameters, which are documented in
    /// {DataTypes}.
    /// @param lockupLinear The address of the {SablierV2LockupLinear} contract.
    /// @param streamDurations The durations for each stream.
    /// @param aggregateAmount The total amount of ERC-20 assets to be distributed to all recipients.
    /// @param recipientCount The total number of recipients who are eligible to claim.
    /// @return merkleLockupLL The address of the newly created MerkleLockup contract.
    function createMerkleLockupLL(
        MerkleLockup.ConstructorParams memory baseParams,
        ISablierV2LockupLinear lockupLinear,
        LockupLinear.Durations memory streamDurations,
        uint256 aggregateAmount,
        uint256 recipientCount
    )
        external
        returns (ISablierV2MerkleLockupLL merkleLockupLL);

    /// @notice Creates a new MerkleLockup campaign with a Lockup Tranched distribution.
    /// @dev Emits a {CreateMerkleLockupLT} event.
    ///
    /// Requirements:
    /// - The sum of the tranches' unlock percentages must equal 100% = 1e18.
    ///
    /// @param baseParams Struct encapsulating the {SablierV2MerkleLockup} parameters, which are documented in
    /// {DataTypes}.
    /// @param lockupTranched The address of the {SablierV2LockupTranched} contract.
    /// @param tranchesWithPercentages The tranches with their respective unlock percentages.
    /// @param aggregateAmount The total amount of ERC-20 assets to be distributed to all recipients.
    /// @param recipientCount The total number of recipients who are eligible to claim.
    /// @return merkleLockupLT The address of the newly created MerkleLockup contract.
    function createMerkleLockupLT(
        MerkleLockup.ConstructorParams memory baseParams,
        ISablierV2LockupTranched lockupTranched,
        MerkleLockupLT.TrancheWithPercentage[] memory tranchesWithPercentages,
        uint256 aggregateAmount,
        uint256 recipientCount
    )
        external
        returns (ISablierV2MerkleLockupLT merkleLockupLT);
}
