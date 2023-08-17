// SPDX-License-Identifier: GPL-3.0-or-later
// solhint-disable no-unused-import
pragma solidity >=0.8.19;

import { IAllowanceTransfer } from "@uniswap/permit2/interfaces/IAllowanceTransfer.sol";
import { IPermit2 } from "@uniswap/permit2/interfaces/IPermit2.sol"; // unused but re-exported for convenience

/// @notice A struct encapsulating the parameters needed for Permit2.
/// @dev See the full documentation at https://github.com/Uniswap/permit2.
/// @param permitSingle The permit message signed for a single token allowance.
/// @param signature The ECDSA signature of the permit, which contains the three parameters (r,s,v).
struct Permit2Params {
    IAllowanceTransfer.PermitSingle permitSingle;
    bytes signature;
}
