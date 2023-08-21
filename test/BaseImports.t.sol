// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

// solhint-disable no-unused-import

// This file re-exports all files needed in the {Base_Test}.

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { IPRBProxy } from "@prb/proxy/src/interfaces/IPRBProxy.sol";
import { IPRBProxyRegistry } from "@prb/proxy/src/interfaces/IPRBProxyRegistry.sol";
import { ISablierV2Lockup } from "@sablier/v2-core/src/interfaces/ISablierV2Lockup.sol";
import { ISablierV2LockupDynamic } from "@sablier/v2-core/src/interfaces/ISablierV2LockupDynamic.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { LockupDynamic, LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";
import { IAllowanceTransfer } from "@uniswap/permit2/interfaces/IAllowanceTransfer.sol";

import { Utils as V2CoreUtils } from "@sablier/v2-core-test/utils/Utils.sol";
import { StdCheats } from "forge-std/StdCheats.sol";

import { ISablierV2AirstreamCampaignFactory } from "src/interfaces/ISablierV2AirstreamCampaignFactory.sol";
import { ISablierV2AirstreamCampaignLL } from "src/interfaces/ISablierV2AirstreamCampaignLL.sol";
import { ISablierV2Archive } from "src/interfaces/ISablierV2Archive.sol";
import { ISablierV2ProxyPlugin } from "src/interfaces/ISablierV2ProxyPlugin.sol";
import { ISablierV2ProxyTarget } from "src/interfaces/ISablierV2ProxyTarget.sol";
import { IWrappedNativeAsset } from "src/interfaces/IWrappedNativeAsset.sol";
import { SablierV2AirstreamCampaignFactory } from "src/SablierV2AirstreamCampaignFactory.sol";
import { SablierV2AirstreamCampaignLL } from "src/SablierV2AirstreamCampaignLL.sol";
import { SablierV2Archive } from "src/SablierV2Archive.sol";
import { SablierV2ProxyPlugin } from "src/SablierV2ProxyPlugin.sol";
import { SablierV2ProxyTargetApprove } from "src/SablierV2ProxyTargetApprove.sol";
import { SablierV2ProxyTargetPermit2 } from "src/SablierV2ProxyTargetPermit2.sol";

import { WLC } from "./mocks/WLC.sol";
import { Assertions } from "./utils/Assertions.sol";
import { Defaults } from "./utils/Defaults.sol";
import { Events } from "./utils/Events.sol";
import { Users } from "./utils/Types.sol";
