// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";

import { ISablierV2MerkleStreamerLL } from "src/interfaces/ISablierV2MerkleStreamerLL.sol";

/// @notice Abstract contract containing all the events emitted by the protocol.
abstract contract Events {
    event Claim(uint256 index, address indexed recipient, uint128 amount, uint256 indexed streamId);
    event Clawback(address indexed admin, address indexed to, uint128 amount);
    event CreateMerkleStreamerLL(
        ISablierV2MerkleStreamerLL merkleStreamer,
        address indexed admin,
        ISablierV2LockupLinear indexed lockupLinear,
        IERC20 indexed asset,
        bytes32 merkleRoot,
        uint40 expiration,
        LockupLinear.Durations streamDurations,
        bool cancelable,
        bool transferable,
        string ipfsCID,
        uint256 aggregateAmount,
        uint256 recipientsCount
    );
}
