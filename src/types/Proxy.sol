// SPDX-License-Identifier: GPL-3.0-or-later
// solhint-disable no-unused-import
pragma solidity >=0.8.19;

// Proxy.sol
//
// This file re-exports all PRBProxy interfaces used in V2 Periphery. It is provided for convenience so
// that users don't have to install PRBProxy separately.

import { IPRBProxy } from "@prb/proxy/src/interfaces/IPRBProxy.sol";
import { IPRBProxyRegistry } from "@prb/proxy/src/interfaces/IPRBProxyRegistry.sol";
