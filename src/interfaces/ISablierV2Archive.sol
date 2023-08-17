// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IAdminable } from "@sablier/v2-core/src/interfaces/IAdminable.sol";

/// @title ISablierV2Archive
/// @notice An on-chain contract registry that keeps a record of all Sablier V2 contracts, including old deployments.
interface ISablierV2Archive is IAdminable {
    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when an address is listed in the archive.
    event List(address indexed admin, address indexed addr);

    /// @notice Emitted when an address is unlisted from the archive.
    event Unlist(address indexed admin, address indexed addr);

    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice A boolean flag that indicates whether the provided address is part of the archive.
    function isListed(address addr) external returns (bool result);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Lists an address in the archive.
    /// @dev Emits a {List} event.
    ///
    /// Notes:
    /// - It is not an error to list an address that is already listed.
    ///
    /// Requirements:
    /// - The caller must be the admin.
    ///
    /// @param addr The address to list in the archive, which should be a contract.
    function list(address addr) external;

    /// @notice Unlists an address from the archive.
    /// @dev Emits an {Unlist} event.
    ///
    /// Notes:
    /// - It is not an error to unlist an address that is not already listed.
    ///
    /// Requirements:
    /// - The caller must be the admin.
    ///
    /// @param addr The address to unlist from the archive, which is usually a contract address.
    function unlist(address addr) external;
}
