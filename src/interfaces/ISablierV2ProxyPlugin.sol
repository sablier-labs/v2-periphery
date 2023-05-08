// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { ISablierV2LockupSender } from "@sablier/v2-core/interfaces/hooks/ISablierV2LockupSender.sol";
import { IPRBProxyPlugin } from "@prb/proxy/interfaces/IPRBProxyPlugin.sol";

import { ISablierV2ChainLog } from "./ISablierV2ChainLog.sol";

/// @title ISablierV2ProxyPlugin
/// @notice Proxy plugin for forwarding the refunded assets to the proxy owner when the recipient cancels a stream
/// whose sender is the proxy contract.
/// @dev Requirements:
/// - The call must not be a standard call.
/// - The caller must be Sablier.
interface ISablierV2ProxyPlugin is
    ISablierV2LockupSender, // 0 inherited components
    IPRBProxyPlugin // 1 inherited component
{
    /// @notice Retrieves the address of the chain log contract.
    function chainLog() external view returns (ISablierV2ChainLog);
}
