// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ISablierV2Lockup } from "@sablier/v2-core/src/interfaces/ISablierV2Lockup.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { ISablierV2LockupDynamic } from "@sablier/v2-core/src/interfaces/ISablierV2LockupDynamic.sol";
import { LockupDynamic, LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { Batch } from "../types/DataTypes.sol";
import { Permit2Params } from "../types/Permit2.sol";

/// @title ISablierV2ProxyTarget
/// @notice Proxy target with stateless scripts for interacting with Sablier V2, designed to be used by
/// stream senders.
/// @dev Intended for use with an instance of PRBProxy through delegate calls. Any standard calls will be reverted.
interface ISablierV2ProxyTarget {
    /*//////////////////////////////////////////////////////////////////////////
                                 SABLIER-V2-LOCKUP
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Cancels multiple streams across different lockup contracts.
    ///
    /// @dev Notes:
    /// - All refunded assets are forwarded to the proxy owner.
    /// - It is assumed that `assets` includes only the assets associated with the stream ids in `batch`. If any asset
    /// is missing, the refunded amount will be left in the proxy.
    ///
    /// Requirements:
    /// - Must be delegate called.
    /// - There must be at least one element in `batch`.
    ///
    /// @param batch An array of structs, each encapsulating the lockup contract's address and the stream id to cancel.
    /// @param assets The contract addresses of the ERC-20 assets used for streaming.
    function batchCancelMultiple(Batch.CancelMultiple[] calldata batch, IERC20[] calldata assets) external;

    /// @notice Mirror for {ISablierV2Lockup.burn}.
    /// @dev Must be delegate called.
    function burn(ISablierV2Lockup lockup, uint256 streamId) external;

    /// @notice Mirror for {ISablierV2Lockup.cancel}.
    ///
    /// @dev Notes:
    /// - All refunded assets are forwarded to the proxy owner.
    ///
    /// Requirements:
    /// - Must be delegate called.
    function cancel(ISablierV2Lockup lockup, uint256 streamId) external;

    /// @notice Mirror for {ISablierV2Lockup.cancelMultiple}.
    ///
    /// @dev Notes:
    /// - All refunded assets are forwarded to the proxy owner.
    /// - It is assumed that `assets` includes only the assets associated with `streamIds`. If any asset is missing, the
    /// refunded amount will be left in the proxy.
    ///
    /// Requirements:
    /// - Must be delegate called.
    ///
    /// @param lockup The address of the Lockup streaming contract.
    /// @param assets The contract addresses of the ERC-20 assets used for streaming.
    /// @param streamIds The stream ids to cancel.
    function cancelMultiple(ISablierV2Lockup lockup, IERC20[] calldata assets, uint256[] calldata streamIds) external;

    /// @notice Mirror for {ISablierV2Lockup.renounce}.
    /// @dev Must be delegate called.
    function renounce(ISablierV2Lockup lockup, uint256 streamId) external;

    /// @notice Mirror for {ISablierV2Lockup.withdraw}.
    /// @dev Must be delegate called.
    function withdraw(ISablierV2Lockup lockup, uint256 streamId, address to, uint128 amount) external;

    /// @notice Mirror for {ISablierV2Lockup.withdrawMax}.
    /// @dev Must be delegate called.
    function withdrawMax(ISablierV2Lockup lockup, uint256 streamId, address to) external;

    /// @notice Mirror for {ISablierV2Lockup.withdrawMaxAndTransfer}.
    /// @dev Must be delegate called.
    function withdrawMaxAndTransfer(ISablierV2Lockup lockup, uint256 streamId, address newRecipient) external;

    /// @notice Mirror for {ISablierV2Lockup.withdrawMultiple}.
    /// @dev Must be delegate called.
    function withdrawMultiple(
        ISablierV2Lockup lockup,
        uint256[] calldata streamIds,
        address to,
        uint128[] calldata amounts
    )
        external;

    /*//////////////////////////////////////////////////////////////////////////
                              SABLIER-V2-LOCKUP-LINEAR
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Creates a batch of Lockup Linear streams using `createWithDurations`. Assets are transferred to the
    /// proxy via Permit2.
    ///
    /// @dev Requirements:
    /// - Must be delegate called.
    /// - There must be at least one element in `batch`.
    /// - All requirements from {ISablierV2LockupLinear.createWithDurations} must be met for each stream.
    ///
    /// @param lockupLinear The address of the {SablierV2LockupLinear} contract.
    /// @param asset The contract address of the ERC-20 asset used for streaming.
    /// @param batch An array of structs, each encapsulating a subset of the parameters of
    /// {SablierV2LockupLinear.createWithDurations}.
    /// @param permit2Params A struct encapsulating the parameters needed for Permit2, most importantly the signature.
    /// @return streamIds The ids of the newly created streams.
    function batchCreateWithDurations(
        ISablierV2LockupLinear lockupLinear,
        IERC20 asset,
        Batch.CreateWithDurations[] calldata batch,
        Permit2Params calldata permit2Params
    )
        external
        returns (uint256[] memory streamIds);

    /// @notice Creates a batch of Lockup Linear streams using `createWithRange`. Assets are transferred to the proxy
    /// via Permit2.
    ///
    /// @dev Requirements:
    /// - Must be delegate called.
    /// - There must be at least one element in `batch`.
    /// - All requirements from {ISablierV2LockupLinear.createWithRange} must be met for each stream.
    ///
    /// @param lockupLinear The address of the {SablierV2LockupLinear} contract.
    /// @param asset The contract address of the ERC-20 asset used for streaming.
    /// @param batch An array of structs, each encapsulating a subset of the parameters of
    /// {SablierV2LockupLinear.createWithRange}.
    /// @param permit2Params A struct encapsulating the parameters needed for Permit2, most importantly the signature.
    /// @return streamIds The ids of the newly created streams.
    function batchCreateWithRange(
        ISablierV2LockupLinear lockupLinear,
        IERC20 asset,
        Batch.CreateWithRange[] calldata batch,
        Permit2Params calldata permit2Params
    )
        external
        returns (uint256[] memory streamIds);

    /// @notice Cancels a Lockup stream and creates a new Lockup Linear stream using `createWithDurations`. Assets are
    /// transferred to the proxy via Permit2.
    ///
    /// @dev Notes:
    /// - `streamId` can reference either a Lockup Linear or a Lockup Dynamic stream.
    /// - See {ISablierV2Lockup.cancel} and {ISablierV2LockupLinear.createWithDurations} for full documentation.
    ///
    /// Requirements:
    /// - Must be delegate called.
    ///
    /// @param lockup The address of the Lockup streaming contract where the stream to cancel is.
    /// @param lockupLinear The address of the {SablierV2LockupLinear} contract to use for creating the new stream.
    /// @param streamId The id of the stream to cancel.
    /// @param permit2Params A struct encapsulating the parameters needed for Permit2, most importantly the signature.
    /// @return newStreamId The id of the newly created stream.
    function cancelAndCreateWithDurations(
        ISablierV2Lockup lockup,
        uint256 streamId,
        ISablierV2LockupLinear lockupLinear,
        LockupLinear.CreateWithDurations calldata createParams,
        Permit2Params calldata permit2Params
    )
        external
        returns (uint256 newStreamId);

    /// @notice Cancels a Lockup stream and creates a new Lockup Linear stream using `createWithRange`. Assets are
    /// transferred to the proxy via Permit2.
    ///
    /// @dev Notes:
    /// - `streamId` can reference either a Lockup Linear or a Lockup Dynamic stream.
    /// - See {ISablierV2Lockup.cancel} and {ISablierV2LockupLinear.createWithRange} for full documentation.
    ///
    /// Requirements:
    /// - Must be delegate called.
    ///
    /// @param lockup The address of the Lockup streaming contract where the stream to cancel is.
    /// @param streamId The id of the stream to cancel.
    /// @param lockupLinear The address of the {SablierV2LockupLinear} contract to use for creating the new stream.
    /// @param permit2Params A struct encapsulating the parameters needed for Permit2, most importantly the signature.
    /// @return newStreamId The id of the newly created stream.
    function cancelAndCreateWithRange(
        ISablierV2Lockup lockup,
        uint256 streamId,
        ISablierV2LockupLinear lockupLinear,
        LockupLinear.CreateWithRange calldata createParams,
        Permit2Params calldata permit2Params
    )
        external
        returns (uint256 newStreamId);

    /// @notice Mirror for {SablierV2LockupLinear.createWithDurations}. Assets are transferred to the proxy via Permit2.
    /// @dev Must be delegate called.
    /// @param lockupLinear The address of the {SablierV2LockupLinear} contract.
    /// @param createParams Struct encapsulating the function parameters, which are documented in V2 Core.
    /// @param permit2Params A struct encapsulating the parameters needed for Permit2, most importantly the signature.
    /// @return streamId The id of the newly created stream.
    function createWithDurations(
        ISablierV2LockupLinear lockupLinear,
        LockupLinear.CreateWithDurations calldata createParams,
        Permit2Params calldata permit2Params
    )
        external
        returns (uint256 streamId);

    /// @notice Mirror for {SablierV2LockupLinear.createWithRange}. Assets are transferred to the proxy via Permit2.
    /// @dev Must be delegate called.
    /// @param lockupLinear The address of the {SablierV2LockupLinear} contract.
    /// @param createParams Struct encapsulating the function parameters, which are documented in V2 Core.
    /// @param permit2Params A struct encapsulating the parameters needed for Permit2, most importantly the signature.
    /// @return streamId The id of the newly created stream.
    function createWithRange(
        ISablierV2LockupLinear lockupLinear,
        LockupLinear.CreateWithRange calldata createParams,
        Permit2Params calldata permit2Params
    )
        external
        returns (uint256 streamId);

    /// @notice Wraps the native asset payment in ERC-20 form and creates a Lockup Linear stream using
    /// `createWithDurations`.
    ///
    /// @dev Notes:
    /// - `createParams.totalAmount` is overwritten with `msg.value`.
    /// - See {ISablierV2LockupLinear.createWithDurations} for full documentation.
    ///
    /// Requirements:
    /// - Must be delegate called.
    /// - The ERC-20 amount credited by the wrapper contract must be equal to `msg.value`.
    ///
    /// @param lockupLinear The address of the {SablierV2LockupLinear} contract.
    /// @param createParams Struct encapsulating the function parameters, which are documented in V2 Core.
    function wrapAndCreateWithDurations(
        ISablierV2LockupLinear lockupLinear,
        LockupLinear.CreateWithDurations memory createParams
    )
        external
        payable
        returns (uint256 streamId);

    /// @notice Wraps the native asset payment in ERC-20 form and creates a Lockup Linear stream using
    /// `createWithRange`.
    ///
    /// @dev Notes:
    /// - `createParams.totalAmount` is overwritten with `msg.value`.
    /// - See {ISablierV2LockupLinear.createWithRange} for full documentation.
    ///
    /// Requirements:
    /// - Must be delegate called.
    /// - The ERC-20 amount credited by the wrapper contract must be equal to `msg.value`.
    ///
    /// @param lockupLinear The address of the {SablierV2LockupLinear} contract.
    /// @param createParams Struct encapsulating the function parameters, which are documented in V2 Core.
    function wrapAndCreateWithRange(
        ISablierV2LockupLinear lockupLinear,
        LockupLinear.CreateWithRange memory createParams
    )
        external
        payable
        returns (uint256 streamId);

    /*//////////////////////////////////////////////////////////////////////////
                             SABLIER-V2-LOCKUP-DYNAMIC
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Creates a batch of Lockup Dynamic streams using `createWithDeltas`. Assets are transferred to the proxy
    /// via Permit2.
    ///
    /// @dev Requirements:
    /// - Must be delegate called.
    /// - There must be at least one element in `batch`.
    /// - All requirements from {ISablierV2LockupDynamic.createWithDeltas} must be met for each stream.
    ///
    /// @param lockupDynamic The address of the {SablierV2LockupDynamic} contract.
    /// @param asset The contract address of the ERC-20 asset used for streaming.
    /// @param batch An array of structs, each encapsulating a subset of the parameters of
    /// {SablierV2LockupDynamic.createWithDeltas}.
    /// @param permit2Params A struct encapsulating the parameters needed for Permit2, most importantly the signature.
    /// @return streamIds The ids of the newly created streams.
    function batchCreateWithDeltas(
        ISablierV2LockupDynamic lockupDynamic,
        IERC20 asset,
        Batch.CreateWithDeltas[] calldata batch,
        Permit2Params calldata permit2Params
    )
        external
        returns (uint256[] memory streamIds);

    /// @notice Creates a batch of Lockup Dynamic streams using `createWithMilestones`. Assets are transferred to the
    /// proxy via Permit2.
    ///
    /// @dev Requirements:
    /// - Must be delegate called.
    /// - There must be at least one element in `batch`.
    /// - All requirements from {ISablierV2LockupDynamic.createWithMilestones} must be met for each stream.
    ///
    /// @param lockupDynamic The address of the {SablierV2LockupDynamic} contract.
    /// @param asset The contract address of the ERC-20 asset used for streaming.
    /// @param batch An array of structs, each encapsulating a subset of the parameters of
    /// {SablierV2LockupDynamic.createWithMilestones}.
    /// @param permit2Params A struct encapsulating the parameters needed for Permit2, most importantly the signature.
    /// @return streamIds The ids of the newly created streams.
    function batchCreateWithMilestones(
        ISablierV2LockupDynamic lockupDynamic,
        IERC20 asset,
        Batch.CreateWithMilestones[] calldata batch,
        Permit2Params calldata permit2Params
    )
        external
        returns (uint256[] memory streamIds);

    /// @notice Cancels a Lockup stream and creates a new Lockup Dynamic stream using `createWithDeltas`. Assets are
    /// transferred to the proxy via Permit2.
    ///
    /// @dev Notes:
    /// - `streamId` can reference either a Lockup Linear or a Lockup Dynamic stream.
    /// - See {ISablierV2Lockup.cancel} and {ISablierV2LockupDynamic.createWithDeltas} for full documentation.
    ///
    /// Requirements:
    /// - Must be delegate called.
    ///
    /// @param lockup The address of the Lockup streaming contract where the stream to cancel is.
    /// @param streamId The id of the stream to cancel.
    /// @param lockupDynamic The address of the {SablierV2LockupDynamic} contract to use for creating the new stream.
    /// @param createParams A struct encapsulating the create function parameters, which are documented in V2 Core.
    /// @param permit2Params A struct encapsulating the parameters needed for Permit2, most importantly the signature.
    /// @return newStreamId The id of the newly created stream.
    function cancelAndCreateWithDeltas(
        ISablierV2Lockup lockup,
        uint256 streamId,
        ISablierV2LockupDynamic lockupDynamic,
        LockupDynamic.CreateWithDeltas calldata createParams,
        Permit2Params calldata permit2Params
    )
        external
        returns (uint256 newStreamId);

    /// @notice Cancels a Lockup stream and creates a new Lockup Dynamic stream using `createWithMilestones`. Assets are
    /// transferred to the proxy via Permit2.
    ///
    /// @dev Notes:
    /// - `streamId` can reference either a Lockup Linear or a Lockup Dynamic stream.
    /// - See {ISablierV2Lockup.cancel} and {ISablierV2LockupDynamic.createWithMilestones} for full documentation.
    ///
    /// Requirements:
    /// - Must be delegate called.
    ///
    /// @param lockup The address of the Lockup streaming contract where the stream to cancel is.
    /// @param streamId The id of the stream to cancel.
    /// @param lockupDynamic The address of the {SablierV2LockupDynamic} contract to use for creating the new stream.
    /// @param createParams A struct encapsulating the create function parameters, which are documented in V2 Core.
    /// @param permit2Params A struct encapsulating the parameters needed for Permit2, most importantly the signature.
    /// @return newStreamId The id of the newly created stream.
    function cancelAndCreateWithMilestones(
        ISablierV2Lockup lockup,
        uint256 streamId,
        ISablierV2LockupDynamic lockupDynamic,
        LockupDynamic.CreateWithMilestones calldata createParams,
        Permit2Params calldata permit2Params
    )
        external
        returns (uint256 newStreamId);

    /// @notice Mirror for {SablierV2LockupDynamic.createWithDeltas}. Assets are transferred to the proxy via Permit2.
    /// @dev Must be delegate called.
    /// @param lockupDynamic The address of the {SablierV2LockupDynamic} contract.
    /// @param createParams A struct encapsulating the create function parameters, which are documented in V2 Core.
    /// @param permit2Params A struct encapsulating the parameters needed for Permit2, most importantly the signature.
    /// @return streamId The id of the newly created stream.
    function createWithDeltas(
        ISablierV2LockupDynamic lockupDynamic,
        LockupDynamic.CreateWithDeltas calldata createParams,
        Permit2Params calldata permit2Params
    )
        external
        returns (uint256 streamId);

    /// @notice Mirror for {SablierV2LockupDynamic.createWithMilestones}. Assets are transferred to the proxy via
    /// Permit2.
    /// @dev Must be delegate called.
    /// @param lockupDynamic The address of the {SablierV2LockupDynamic} contract.
    /// @param createParams Struct encapsulating the function parameters, which are documented in V2 Core.
    /// @param permit2Params A struct encapsulating the parameters needed for Permit2, most importantly the signature.
    /// @return streamId The id of the newly created stream.
    function createWithMilestones(
        ISablierV2LockupDynamic lockupDynamic,
        LockupDynamic.CreateWithMilestones calldata createParams,
        Permit2Params calldata permit2Params
    )
        external
        returns (uint256 streamId);

    /// @notice Wraps the native asset payment in ERC-20 form and creates a Lockup Dynamic stream using
    /// `createWithDeltas`.
    ///
    /// @dev Notes:
    /// - `createParams.totalAmount` is overwritten with `msg.value`.
    /// - See {ISablierV2LockupDynamic.createWithDeltas} for full documentation.
    ///
    /// Requirements:
    /// - Must be delegate called.
    /// - The ERC-20 amount credited by the wrapper contract must be equal to `msg.value`.
    ///
    /// @param lockupDynamic The address of the {SablierV2LockupDynamic} contract.
    /// @param createParams Struct encapsulating the function parameters, which are documented in V2 Core.
    /// @return streamId The id of the newly created stream.
    function wrapAndCreateWithDeltas(
        ISablierV2LockupDynamic lockupDynamic,
        LockupDynamic.CreateWithDeltas memory createParams
    )
        external
        payable
        returns (uint256 streamId);

    /// @notice Wraps the native asset payment in ERC-20 form and creates a Lockup Dynamic stream using
    /// `createWithMilestones`.
    ///
    /// @dev Notes:
    /// - `createParams.totalAmount` is overwritten with `msg.value`.
    /// - See {ISablierV2LockupDynamic.createWithMilestones} for full documentation.
    ///
    /// Requirements:
    /// - Must be delegate called.
    /// - The ERC-20 amount credited by the wrapper contract must be equal to `msg.value`.
    ///
    /// @param lockupDynamic The address of the {SablierV2LockupDynamic} contract.
    /// @param createParams Struct encapsulating the function parameters, which are documented in V2 Core.
    /// @return streamId The id of the newly created stream.
    function wrapAndCreateWithMilestones(
        ISablierV2LockupDynamic lockupDynamic,
        LockupDynamic.CreateWithMilestones memory createParams
    )
        external
        payable
        returns (uint256 streamId);
}
