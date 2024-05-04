// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IAdminable } from "@sablier/v2-core/src/interfaces/IAdminable.sol";
import { ISablierV2Lockup } from "@sablier/v2-core/src/interfaces/ISablierV2Lockup.sol";

/// @title ISablierV2MerkleStreamer
/// @notice A contract that lets user claim Sablier streams using Merkle proofs. An interesting use case for
/// MerkleStream is airstreams, which is a portmanteau of "airdrop" and "stream". This is an airdrop model where the
/// tokens are distributed over time, as opposed to all at once.
/// @dev This is the base interface for MerkleStreamer contracts. See the Sablier docs for more guidance on how
/// streaming works: https://docs.sablier.com/.
interface ISablierV2MerkleStreamer is IAdminable {
    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a recipient claims a stream.
    event Claim(uint256 index, address indexed recipient, uint128 amount, uint256 indexed streamId);

    /// @notice Emitted when the admin claws back the unclaimed tokens.
    event Clawback(address indexed admin, address indexed to, uint128 amount);

    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice The streamed ERC-20 asset.
    /// @dev This is an immutable state variable.
    function ASSET() external returns (IERC20);

    /// @notice A flag indicating whether the streams can be canceled.
    /// @dev This is an immutable state variable.
    function CANCELABLE() external returns (bool);

    /// @notice The cut-off point for the Merkle streamer, as a Unix timestamp. A value of zero means there
    /// is no expiration.
    /// @dev This is an immutable state variable.
    function EXPIRATION() external returns (uint40);

    /// @notice Returns a flag indicating whether a claim has been made for a given index.
    /// @dev Uses a bitmap to save gas.
    /// @param index The index of the recipient to check.
    function hasClaimed(uint256 index) external returns (bool);

    /// @notice Returns a flag indicating whether the Merkle streamer has expired.
    function hasExpired() external view returns (bool);

    /// @notice The address of the {SablierV2Lockup} contract.
    function LOCKUP() external returns (ISablierV2Lockup);

    /// @notice The root of the Merkle tree used to validate the claims.
    /// @dev This is an immutable state variable.
    function MERKLE_ROOT() external returns (bytes32);

    /// @notice A flag indicating whether the stream NFTs are transferable.
    /// @dev This is an immutable state variable.
    function TRANSFERABLE() external returns (bool);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Claws back the unclaimed tokens from the Merkle streamer.
    ///
    /// @dev Emits a {Clawback} event.
    ///
    /// Notes:
    /// - If the protocol is not zero, the expiration check is not made.
    ///
    /// Requirements:
    /// - The caller must be the admin.
    /// - The campaign must either be expired or not have an expiration.
    ///
    /// @param to The address to receive the tokens.
    /// @param amount The amount of tokens to claw back.
    function clawback(address to, uint128 amount) external;
}
