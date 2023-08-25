// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IAdminable } from "@sablier/v2-core/src/interfaces/IAdminable.sol";

/// @title ISablierV2AirstreamCampaign
/// @notice Airstream is a portmanteau of "airdrop" and "stream". It refers to an airdrop model where the tokens
/// are distributed over time, as opposed to all at once.
/// @dev This is the base interface for Airstream contracts. See the Sablier docs for more guidance on how streaming
/// works: https://docs.sablier.com/
interface ISablierV2AirstreamCampaign is IAdminable {
    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a recipient claims an airstream.
    event Claim(uint256 index, address indexed recipient, uint128 amount, uint256 indexed airstreamId);

    /// @notice Emitted when the admin claws back the unclaimed tokens.
    event Clawback(address indexed admin, address indexed to, uint128 amount);

    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice The airstreamed ERC-20 asset.
    /// @dev This is an immutable state variable.
    function asset() external returns (IERC20);

    /// @notice A flag indicating whether the airstreams can be canceled.
    /// @dev This is an immutable state variable.
    function cancelable() external returns (bool);

    /// @notice The cut-off point for the airstream campaign, as a Unix timestamp. A value of zero means there
    /// is no expiration.
    /// @dev This is an immutable state variable.
    function expiration() external returns (uint40);

    /// @notice Checks whether a claim has been made for a given index.
    /// @param index The index of the recipient to check.
    /// @return Whether the claim has been made.
    function hasClaimed(uint256 index) external returns (bool);

    /// @notice Returns whether the airstream campaign has expired.
    function hasExpired() external view returns (bool);

    /// @notice The root of the Merkle tree used to validate the claims.
    /// @dev This is an immutable state variable.
    function merkleRoot() external returns (bytes32);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Claws back the unclaimed tokens from the airstream campaign.
    ///
    /// @dev Emits a {Clawback} event.
    ///
    /// Requirements:
    /// - The caller must be the admin.
    /// - The airstream campaign must have expired.
    ///
    /// @param to The address to receive the tokens.
    /// @param amount The amount of tokens to claw back.
    function clawback(address to, uint128 amount) external;
}
