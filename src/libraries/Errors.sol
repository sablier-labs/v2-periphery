// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";

import { IWETH9 } from "../interfaces/IWETH9.sol";

library Errors {
    /*//////////////////////////////////////////////////////////////////////////
                                   CUSTOM ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when attempting to create a stream with wrong asset.
    error SablierV2ProxyTarget_AssetNotWETH9(IERC20 asset, IWETH9 weth9);

    /// @notice Emitted when attempting to cancel multiple streams with different assets.
    error SablierV2ProxyTarget_CancelMultipleDifferentAsset(IERC20 asset, IERC20 streamAsset);

    /// @notice Emitted when attempting to wrap ether with a wrong amount.
    error SablierV2ProxyTarget_WrongEtherAmount(uint256 etherAmount, uint256 paramsAmount);

    /// @notice Emitted when attempting to create multiple streams with zero parameters.
    error SablierV2ProxyTarget_ParamsCountZero();

    /// @notice Emitted when attempting to create multiple streams with a total amount that does not equal the
    /// parameters amounts sum.
    error SablierV2ProxyTarget_TotalAmountNotEqualToAmountsSum(uint128 totalDeposit, uint128 amountsSum);

    /// @notice Emitted when attempting to create multiple streams with a zero total amount.
    error SablierV2ProxyTarget_TotalAmountZero();
}
