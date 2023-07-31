// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Adminable } from "@sablier/v2-core/abstracts/Adminable.sol";
import { ISablierV2LockupDynamic } from "@sablier/v2-core/interfaces/ISablierV2LockupDynamic.sol";
import { LockupDynamic } from "@sablier/v2-core/types/DataTypes.sol";

import { SablierV2Airstream } from "./abstracts/SablierV2Airstream.sol";
import { ISablierV2Airstream } from "./interfaces/ISablierV2Airstream.sol";
import { ISablierV2AirstreamLockupDynamic } from "./interfaces/ISablierV2AirstreamLockupDynamic.sol";

contract SablierV2AirstreamLockupDynamic is
    Adminable, // 1 inherit component
    ISablierV2AirstreamLockupDynamic, // 2 inherited components
    SablierV2Airstream // 2 inherited components
{
    /*//////////////////////////////////////////////////////////////////////////
                               USER-FACING CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2AirstreamLockupDynamic
    ISablierV2LockupDynamic public immutable override lockupDynamic;

    /// @inheritdoc ISablierV2AirstreamLockupDynamic
    LockupDynamic.SegmentWithDelta[] public override segments;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Constructs the contract by initializing the immutable state variables.
    constructor(
        IERC20 asset_,
        bytes32 root_,
        bool cancelable_,
        uint40 expiration_,
        ISablierV2LockupDynamic lockupDynamic_,
        LockupDynamic.SegmentWithDelta[] memory segments_
    )
        SablierV2Airstream(lockupDynamic_, asset_, root_, cancelable_, expiration_)
    {
        lockupDynamic = lockupDynamic_;
        uint256 length = segments_.length;
        for (uint256 i = 0; i < length;) {
            segments.push(segments_[i]);
            unchecked {
                i += 1;
            }
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2Airstream
    function claim(
        address recipient,
        uint128 amount,
        bytes32[] calldata merkleProof
    )
        external
        pure
        override
        returns (uint256 airstreamId)
    {
        recipient;
        amount;
        merkleProof;
        airstreamId = 0;
    }
}
