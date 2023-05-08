// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

/// @title Events
/// @notice Abstract contract containing all the events emitted by the protocol.
abstract contract Events {
    event ListAddress(address indexed admin, address indexed addr);
}
