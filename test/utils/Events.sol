// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

/// @title Events
/// @notice Abstract contract containing all the events emitted by the protocol.
abstract contract Events {
    event List(address indexed admin, address indexed addr);
    event Unlist(address indexed admin, address indexed addr);
}
