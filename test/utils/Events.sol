// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";
import { ISablierV2LockupDynamic } from "@sablier/v2-core/src/interfaces/ISablierV2LockupDynamic.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";

import { ISablierV2MerkleLockupLD } from "src/interfaces/ISablierV2MerkleLockupLD.sol";
import { ISablierV2MerkleLockupLL } from "src/interfaces/ISablierV2MerkleLockupLL.sol";
import { MerkleLockup } from "src/types/DataTypes.sol";

/// @notice Abstract contract containing all the events emitted by the protocol.
abstract contract Events {
    event Claim(uint256 index, address indexed recipient, uint128 amount, uint256 indexed streamId);

    event Clawback(address indexed admin, address indexed to, uint128 amount);

    event CreateMerkleLockupLD(
        ISablierV2MerkleLockupLD indexed merkleLockupLD,
        MerkleLockup.ConstructorParams indexed baseParams,
        ISablierV2LockupDynamic lockupDynamic,
        string ipfsCID,
        uint256 aggregateAmount,
        uint256 recipientsCount
    );

    event CreateMerkleLockupLL(
        ISablierV2MerkleLockupLL indexed merkleLockupLL,
        MerkleLockup.ConstructorParams indexed baseParams,
        ISablierV2LockupLinear lockupLinear,
        LockupLinear.Durations streamDurations,
        string ipfsCID,
        uint256 aggregateAmount,
        uint256 recipientsCount
    );
}
