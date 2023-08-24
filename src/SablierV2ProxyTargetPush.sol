    // SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { SablierV2ProxyTarget } from "./abstracts/SablierV2ProxyTarget.sol";

/// @title SablierV2ProxyTargetPush
/// @notice Proxy target contract that implements a push-based model for transferring funds.
contract SablierV2ProxyTargetPush is SablierV2ProxyTarget {
    using SafeERC20 for IERC20;

    /// @notice The name of this function is a bit misleading, as it does not actually transfer assets to the proxy. That
    /// is left for the user to do. Instead, this function only approves the Sablier contract to spend the funds. Still,
    /// the name is retained so that the logic defined in {SablierV2ProxyTarget} can be reused.
    /// @dev The `transferData` data is ignored in this implementation.
    function _handleTransfer(
        address sablierContract,
        IERC20 asset,
        uint160 amount,
        bytes calldata /* transferData */
    )
        internal
        override
    {
        // Approve the Sablier contract to spend funds.
        _approve(sablierContract, asset, amount);
    }
}
