    // SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IAllowanceTransfer } from "@uniswap/permit2/interfaces/IAllowanceTransfer.sol";

import { SablierV2ProxyTarget } from "./abstracts/SablierV2ProxyTarget.sol";
import { Permit2Params } from "./types/Permit2.sol";

contract SablierV2ProxyTargetERC20 is SablierV2ProxyTarget {
    using SafeERC20 for IERC20;

    /// @dev Helper function to transfer funds from the proxy owner to the proxy using Permit2 and, if needed, approve
    /// the Sablier contract to spend funds from the proxy.
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
