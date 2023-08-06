    // SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IAllowanceTransfer } from "@uniswap/permit2/interfaces/IAllowanceTransfer.sol";

import { SablierV2ProxyTarget } from "./abstracts/SablierV2ProxyTarget.sol";
import { Permit2Params } from "./types/Permit2.sol";

contract SablierV2ProxyTargetPermit2 is SablierV2ProxyTarget {
    using SafeERC20 for IERC20;

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

    function _transferAndApprove(
        address sablierContract,
        IERC20 asset,
        uint128 amount,
        Permit2Params calldata permit2Params
    )
        internal
        override
    {
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
