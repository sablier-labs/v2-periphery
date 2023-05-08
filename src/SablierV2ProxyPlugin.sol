// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import { PRBProxyPlugin } from "@prb/proxy/abstracts/PRBProxyPlugin.sol";
import { IPRBProxyPlugin } from "@prb/proxy/interfaces/IPRBProxyPlugin.sol";
import { ISablierV2Lockup } from "@sablier/v2-core/interfaces/ISablierV2Lockup.sol";
import { ISablierV2LockupSender } from "@sablier/v2-core/interfaces/hooks/ISablierV2LockupSender.sol";

import { NoStandardCall } from "./abstracts/NoStandardCall.sol";
import { ISablierV2ChainLog } from "./interfaces/ISablierV2ChainLog.sol";
import { ISablierV2ProxyPlugin } from "./interfaces/ISablierV2ProxyPlugin.sol";
import { Errors } from "./libraries/Errors.sol";

contract SablierV2ProxyPlugin is
    ISablierV2ProxyPlugin, // 0 inherited components
    NoStandardCall, // 0 inherited components
    PRBProxyPlugin // 3 inherited components
{
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2ProxyPlugin
    ISablierV2ChainLog public immutable override chainLog;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor(ISablierV2ChainLog chainLog_) {
        chainLog = chainLog_;
    }

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
    /// @notice Forwards the refunded assets to the proxy owner when the recipient cancel a stream whose sender is the
    /// proxy contract.
    /// @dev Requirements:
    /// - The call must not be a standard call.
    /// - The caller must be Sablier.
    function onStreamCanceled(
        ISablierV2Lockup, /* lockup */
        uint256 streamId,
        address, /* recipient */
        uint128 senderAmount,
        uint128 /* recipientAmount */
    )
        external
        noStandardCall
    {
        // Checks: the caller is Sablier.
        if (!chainLog.isListed(msg.sender)) {
            revert Errors.SablierV2ProxyPlugin_CallerNotSablier(msg.sender);
        }

        // This invariant should always hold but it's better to be safe than sorry.
        ISablierV2Lockup lockup = ISablierV2Lockup(msg.sender);
        address streamSender = lockup.getSender(streamId);
        assert(streamSender == address(this));

        // Effects: forward the refunded assets to the proxy owner.
        IERC20 asset = lockup.getAsset(streamId);
        asset.safeTransfer({ to: owner, value: senderAmount });
    }
}
