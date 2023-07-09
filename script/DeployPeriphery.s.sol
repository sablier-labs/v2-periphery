// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <0.9.0;

import { BaseScript } from "@sablier/v2-core-script/Base.s.sol";
import { IAllowanceTransfer } from "@uniswap/permit2/interfaces/IAllowanceTransfer.sol";

import { SablierV2Archive } from "../src/SablierV2Archive.sol";
import { SablierV2ProxyPlugin } from "../src/SablierV2ProxyPlugin.sol";
import { SablierV2ProxyTarget } from "../src/SablierV2ProxyTarget.sol";

/// @notice Deploys all V2 Periphery contract in the following order:
///
/// 1. {SablierV2Archive}
/// 2. {SablierV2ProxyPlugin}
/// 3. {SablierV2ProxyTarget}
contract DeployPeriphery is BaseScript {
    function run(
        address initialAdmin,
        IAllowanceTransfer permit2
    )
        public
        broadcast
        returns (SablierV2Archive archive, SablierV2ProxyPlugin plugin, SablierV2ProxyTarget target)
    {
        archive = new SablierV2Archive(initialAdmin);
        plugin = new SablierV2ProxyPlugin(archive);
        target = new SablierV2ProxyTarget(permit2);
    }
}
