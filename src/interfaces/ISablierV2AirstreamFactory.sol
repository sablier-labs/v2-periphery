// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ISablierV2LockupDynamic } from "@sablier/v2-core/interfaces/ISablierV2LockupDynamic.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";
import { LockupDynamic, LockupLinear } from "@sablier/v2-core/types/DataTypes.sol";

import { ISablierV2AirstreamLockupDynamic } from "./ISablierV2AirstreamLockupDynamic.sol";
import { ISablierV2AirstreamLockupLinear } from "./ISablierV2AirstreamLockupLinear.sol";

interface ISablierV2AirstreamFactory {
    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    event CreateAirstreamLockupDynamic(
        address indexed admin, bytes32 merkleRoot, ISablierV2AirstreamLockupDynamic indexed airstream
    );
    event CreateAirstreamLockupLinear(
        address indexed admin, bytes32 merkleRoot, ISablierV2AirstreamLockupLinear indexed airstream
    );

    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function getAirstreamLockupDynamic(
        address admin,
        IERC20 asset,
        bytes32 merkleRoot,
        uint40 expiration
    )
        external
        view
        returns (ISablierV2AirstreamLockupDynamic);

    function getAirstreamLockupLinear(
        address admin,
        IERC20 asset,
        bytes32 merkleRoot,
        uint40 expiration
    )
        external
        view
        returns (ISablierV2AirstreamLockupLinear);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Creates a new Sablier V2 Dynamic airstream campaign.
    function createAirstreamLockupDynamic(
        address initialAdmin,
        IERC20 asset,
        bytes32 merkleRoot,
        bool cancelable,
        uint40 expiration,
        ISablierV2LockupDynamic lockupDynamic,
        LockupDynamic.SegmentWithDelta[] memory segments
    )
        external
        returns (ISablierV2AirstreamLockupDynamic);

    /// @notice Creates a new Sablier V2 Linear airstream campaign.
    function createAirstreamLockupLinear(
        address initialAdmin,
        IERC20 asset,
        bytes32 merkleRoot,
        bool cancelable,
        uint40 expiration,
        ISablierV2LockupLinear lockupLinear,
        LockupLinear.Durations memory durations
    )
        external
        returns (ISablierV2AirstreamLockupLinear);
}
