// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import { PRBProxyPlugin } from "@prb/proxy/abstracts/PRBProxyPlugin.sol";
import { IPRBProxyPlugin } from "@prb/proxy/interfaces/IPRBProxyPlugin.sol";
import { ISablierV2Lockup } from "@sablier/v2-core/interfaces/ISablierV2Lockup.sol";
import { ISablierV2LockupSender } from "@sablier/v2-core/interfaces/hooks/ISablierV2LockupSender.sol";

import { Errors } from "./libraries/Errors.sol";

contract SablierV2ProxyPlugin is
    ISablierV2LockupSender, // 0 inherited components
    PRBProxyPlugin // 3 inherited components
{
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IPRBProxyPlugin
    function methodList() external pure returns (bytes4[] memory methods) {
        methods = new bytes4[](1);
        methods[0] = this.onStreamCanceled.selector;
    }

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2LockupSender
    /// @dev Forwards the refunded assets to the proxy owner when the recipient triggers a cancellation.
    function onStreamCanceled(
        ISablierV2Lockup lockup,
        uint256 streamId,
        address, /* recipient */
        uint128 senderAmount,
        uint128 /* recipientAmount */
    )
        external
    {
        IERC20 asset = lockup.getAsset(streamId);
        asset.safeTransfer({ to: owner, value: senderAmount });
    }
}