// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IAdminable } from "@sablier/v2-core/interfaces/IAdminable.sol";

/// @title ISablierV2ChainLog
/// @notice A comprehensive registry of all Sablier V2 contract addresses.
interface ISablierV2ChainLog is IAdminable {
    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when an address is listed in the chain log.
    event List(address indexed admin, address indexed addr);

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
    /// Requirements:
    /// - The caller must be the admin.
    ///
    /// @param addr The address to list in the chain log, which is usually a contract address.
    function list(address addr) external;
}
