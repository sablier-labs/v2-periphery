// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

/// @title Errors
/// @notice Library containing all the custom errors the protocol may revert with.
library Errors {
    /// @notice Thrown when attempting to create an empty batch of streams.
    error SablierV2ProxyTarget_BatchEmpty();
}
