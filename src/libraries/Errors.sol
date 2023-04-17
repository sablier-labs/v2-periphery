// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

/// @title Errors
/// @notice Library containing all the custom errors the protocol may revert with.
library Errors {
    /// @notice Thrown when attempting to perform an action that requires the batch size to not be zero.
    error SablierV2ProxyTarget_BatchSizeZero();
}
