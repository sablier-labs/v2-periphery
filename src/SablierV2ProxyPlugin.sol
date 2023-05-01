// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import { IPRBProxy } from "@prb/proxy/interfaces/IPRBProxy.sol";
import { IPRBProxyPlugin } from "@prb/proxy/interfaces/IPRBProxyPlugin.sol";
import { ISablierV2Lockup } from "@sablier/v2-core/interfaces/ISablierV2Lockup.sol";
import { ISablierV2LockupSender } from "@sablier/v2-core/interfaces/hooks/ISablierV2LockupSender.sol";

contract SablierV2ProxyPlugin is IPRBProxyPlugin, ISablierV2LockupSender {
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////////////////
                                HOOK-IMPLEMENTATION
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2LockupSender
    /// @dev This function is necessary to automatically redirect funds to the sender, i.e. the proxy owner, when
    /// recipients trigger cancellations.
    function onStreamCanceled(
        ISablierV2Lockup lockup,
        uint256 streamId,
        address recipient,
        uint128 senderAmount,
        uint128 recipientAmount
    )
        external
    {
        // silence the "Unused function parameter" warning
        recipient;
        recipientAmount;

        // The `lockup` contract will have the proxy contract set as the sender.
        address proxy = lockup.getSender(streamId);
        address owner = IPRBProxy(proxy).owner();

        // Transfer the funds from the proxy contract to the sender.
        IERC20 asset = lockup.getAsset(streamId);
        asset.safeTransfer({ to: owner, value: senderAmount });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    PROXY-PLUGIN
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IPRBProxyPlugin
    function methodList() external pure returns (bytes4[] memory methods) {
        bytes4[] memory functionSig = new bytes4[](1);
        functionSig[0] = this.onStreamCanceled.selector;
        methods = functionSig;
    }
}
