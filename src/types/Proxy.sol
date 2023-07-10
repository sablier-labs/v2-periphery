// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

// Proxy.sol
//
// This file re-exports all PRBProxy interfaces used in V2 Periphery. It is provided for convenience so
// that users don't have to install PRBProxy separately.
// solhint-disable no-unused-import

import { IPRBProxy } from "@prb/proxy/interfaces/IPRBProxy.sol";
import { IPRBProxyPlugin } from "@prb/proxy/interfaces/IPRBProxyPlugin.sol";
import { IPRBProxyRegistry } from "@prb/proxy/interfaces/IPRBProxyRegistry.sol";
