// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

/// @title Errors
/// @notice Library containing all custom errors the protocol may revert with.
library Errors {
    /// @notice Thrown when the address of the context contract is not the stream's sender.
    error SablierV2ProxyPlugin_InvalidCall(address context, address streamSender);

    /// @notice Thrown when trying to perform an action that requires the batch size to not be zero.
    error SablierV2ProxyTarget_BatchSizeZero();
}
