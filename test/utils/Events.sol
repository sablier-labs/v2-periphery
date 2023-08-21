// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { ISablierV2AirstreamCampaignLL } from "src/interfaces/ISablierV2AirstreamCampaignLL.sol";

/// @notice Abstract contract containing all the events emitted by the protocol.
abstract contract Events {
    event Claim(uint256 index, address indexed recipient, uint128 amount, uint256 indexed airstreamId);
    event Clawback(address indexed admin, address indexed to, uint128 amount);
    event CreateAirstreamCampaignLL(
        address indexed admin,
        IERC20 indexed asset,
        ISablierV2AirstreamCampaignLL airstreamCampaign,
        string ipfsCID,
        uint256 campaignTotalAmount,
        uint256 recipientsCount
    );
    event List(address indexed admin, address indexed addr);
    event Unlist(address indexed admin, address indexed addr);
}
