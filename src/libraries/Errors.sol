// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

/// @title Errors
/// @notice Library containing all the custom errors the protocol may revert with.
library Errors {
    /// @notice Thrown when attempting to create a batch of streams with a full amount that does not equal the
    /// sum of all the parameter amounts.
    error SablierV2ProxyTarget_FullAmountNotEqualToAmountsSum(uint128 fullAmount, uint128 amountsSum);

    /// @notice Thrown when attempting to create a batch of streams with a zero full amount.
    error SablierV2ProxyTarget_FullAmountZero();
}
