// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";

/// @title IWrappedNativeAsset
/// @notice An interface for contracts that wrap native assets in ERC-20 form, such as WETH.
/// @dev A generic name is used instead of "WETH" to accommodate chains with different native assets.
interface IWrappedNativeAsset is IERC20 {
    /// @notice Deposits native assets to receive ERC-20 wrapped assets.
    function deposit() external payable;

    /// @notice Withdraws ERC-20 wrapped assets to obtain native assets.
    /// @param amount The amount of ERC-20 wrapped assets to withdraw.
    function withdraw(uint256 amount) external;
}
