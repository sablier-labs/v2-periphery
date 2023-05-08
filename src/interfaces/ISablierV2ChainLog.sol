// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IAdminable } from "@sablier/v2-core/interfaces/IAdminable.sol";

/// @title ISablierV2ChainLog
/// @notice An on-chain contract registry that keeps a record of all Sablier V2 contracts.
/// @dev This is an append-only registry. Once an address is listed, it cannot be removed.
interface ISablierV2ChainLog is IAdminable {
    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when an address is listed in the chain log.
    event ListAddress(address indexed admin, address indexed addr);

    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice A boolean flag that indicates whether the provided address is part of the chain log.
    function isListed(address addr) external returns (bool result);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Lists an address in the chain log.
    /// @dev Emits a {List} event.
    ///
    /// Notes:
    /// - It is not an error to list an address that is already listed.
    /// - This operation is irreversible. A listed address cannot be removed from the chain log.
    ///
    /// Requirements:
    /// - The caller must be the admin.
    ///
    /// @param addr The address to list in the chain log, which is usually a contract address.
    function listAddress(address addr) external;
}
