    // SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { SablierV2ProxyTarget } from "./abstracts/SablierV2ProxyTarget.sol";

/// @title SablierV2ProxyTargetApprove
/// @notice Proxy target contract that implements the transfer logic using standard ERC-20 approvals.
contract SablierV2ProxyTargetApprove is SablierV2ProxyTarget {
    using SafeERC20 for IERC20;

    /// @notice Transfers the given `amount` of `asset` to the Sablier contract using standard the ERC-20
    /// approve and transfer flow, and then approves Sablier to spend the funds.
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
        // Retrieve the proxy owner.
        address owner = _getOwner();

        // Transfer funds from the proxy owner to the proxy.
        asset.safeTransferFrom({ from: owner, to: address(this), value: amount });

        // Approve the Sablier contract to spend funds.
        _approve(sablierContract, asset, amount);
    }
}
