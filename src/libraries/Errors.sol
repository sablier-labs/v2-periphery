// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.19;

library Errors {
    /*//////////////////////////////////////////////////////////////////////////
                                   CUSTOM ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when attempting to create multiple streams with a total amount that does not equal the
    /// parameters amounts sum.
    error SablierV2ProxyTarget_TotalAmountNotEqualToAmountsSum(uint128 totalDeposit, uint128 amountsSum);

    /// @notice Thrown when attempting to create multiple streams with a zero total amount.
    error SablierV2ProxyTarget_TotalAmountZero();
}
