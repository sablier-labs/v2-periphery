    // SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { SablierV2ProxyTarget } from "./abstracts/SablierV2ProxyTarget.sol";

/// @title SablierV2ProxyTargetERC20
/// @notice Proxy target contract that implements the transfer logic for standard ERC-20 approvals.
contract SablierV2ProxyTargetERC20 is SablierV2ProxyTarget {
    /// @notice  Parameter `data` is ignored in this implementation.
    /// @dev See the documentation for the user-facing functions that call this internal function.
    function _transferAndApprove(
        address sablierContract,
        IERC20 asset,
        uint128 amount,
        bytes calldata /* data */
    )
        internal
        override
    {
        // Retrieve the proxy owner.
        address owner = _getOwner();

        // Transfer funds from the proxy owner to the proxy.
        asset.transferFrom({ from: owner, to: address(this), amount: amount });

        // Approve the Sablier contract to spend funds.
        _approve(sablierContract, asset, amount);
    }
}