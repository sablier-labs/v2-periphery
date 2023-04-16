// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";

/// @title WrappedNativeAsset Interface
/// @notice An interface for contracts that wrap native assets, such as WETH.
/// @dev A generic name is used instead of "WETH" to accommodate different chains with various native assets.
interface IWrappedNativeAsset is IERC20 {
    /// @notice Deposits native assets to receive wrapped assets.
    function deposit() external payable;

    /// @notice Withdraws wrapped assets to obtain native assets.
    /// @param amount The amount of wrapped assets to withdraw.
    function withdraw(uint256 amount) external;
}
