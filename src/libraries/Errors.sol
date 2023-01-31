// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.13;

library Errors {
    /*//////////////////////////////////////////////////////////////////////////
                                   CUSTOM ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when attempting to create multiple streams with a total amount that does not equal the
    /// parameters amounts sum.
    error BatchStream_TotalAmountNotEqualToAmountsSum(uint128 totalDeposit, uint128 amountsSum);

    /// @notice Emitted when attempting to create multiple streams with a zero total amount.
    error BatchStream_TotalAmountZero();

    /// @notice Emitted when attempting to create multiple streams with zero parameters.
    error BatchStream_ParamsCountZero();
}
