    // SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IAllowanceTransfer } from "@uniswap/permit2/interfaces/IAllowanceTransfer.sol";

import { SablierV2ProxyTarget } from "./abstracts/SablierV2ProxyTarget.sol";
import { Permit2Params } from "./types/Permit2.sol";

/// @title SablierV2ProxyTargetPermit2
/// @notice Proxy target contract that implements the transfer logic using Permit2.
/// @dev See https://github.com/Uniswap/permit2.
contract SablierV2ProxyTargetPermit2 is SablierV2ProxyTarget {
    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    IAllowanceTransfer internal immutable PERMIT2;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor(IAllowanceTransfer permit2) {
        PERMIT2 = permit2;
    }

    /// @notice Transfers the given `amount` of `asset` to the Sablier contract using Permit2, and then approves Sablier
    /// to spend the funds.
    /// @dev The parameter `transferData` contains an ABI-encoded struct that encapsulates the parameters needed for
    /// Permit2.
    function _transferAndApprove(
        address sablierContract,
        IERC20 asset,
        uint160 amount,
        bytes calldata transferData
    )
        internal
        override
    {
        // Decode the Permit2 parameters.
        Permit2Params memory permit2Params = abi.decode(transferData, (Permit2Params));

        // Retrieve the proxy owner.
        address owner = _getOwner();

        // Permit the proxy to spend funds from the proxy owner.
        PERMIT2.permit({ owner: owner, permitSingle: permit2Params.permitSingle, signature: permit2Params.signature });

        // Transfer funds from the proxy owner to the proxy.
        PERMIT2.transferFrom({ from: owner, to: address(this), amount: amount, token: address(asset) });

        // Approve the Sablier contract to spend funds.
        _approve(sablierContract, asset, amount);
    }
}
