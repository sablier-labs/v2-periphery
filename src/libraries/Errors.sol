// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.18;

library Errors {
    /*//////////////////////////////////////////////////////////////////////////
                                   CUSTOM ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when attempting to create multiple streams with a total amount that does not equal the
    /// parameters amounts sum.
    error SablierV2ProxyTarget_TotalAmountNotEqualToAmountsSum(uint128 totalDeposit, uint128 amountsSum);

    /// @notice Emitted when attempting to create multiple streams with a zero total amount.
    error SablierV2ProxyTarget_TotalAmountZero();

    /// @notice Emitted when attempting to create multiple streams with zero parameters.
    error SablierV2ProxyTarget_ParamsCountZero();
}
