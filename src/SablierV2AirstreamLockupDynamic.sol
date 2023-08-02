// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Adminable } from "@sablier/v2-core/abstracts/Adminable.sol";
import { ISablierV2LockupDynamic } from "@sablier/v2-core/interfaces/ISablierV2LockupDynamic.sol";
import { Broker, LockupDynamic } from "@sablier/v2-core/types/DataTypes.sol";
import { UD60x18 } from "@sablier/v2-core/types/Math.sol";

import { SablierV2Airstream } from "./abstracts/SablierV2Airstream.sol";
import { ISablierV2Airstream } from "./interfaces/ISablierV2Airstream.sol";
import { ISablierV2AirstreamLockupDynamic } from "./interfaces/ISablierV2AirstreamLockupDynamic.sol";

contract SablierV2AirstreamLockupDynamic is
    ISablierV2AirstreamLockupDynamic, // 2 inherited components
    SablierV2Airstream // 4 inherited components
{
    using SafeERC20 for IERC20;

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
        address initialAdmin,
        IERC20 asset_,
        bytes32 merkleRoot_,
        bool cancelable_,
        uint40 expiration_,
        ISablierV2LockupDynamic lockupDynamic_,
        LockupDynamic.SegmentWithDelta[] memory segments_
    )
        SablierV2Airstream(initialAdmin, asset_, merkleRoot_, cancelable_, expiration_)
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
                          INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function _createAirstream(address recipient, uint128 amount) internal override returns (uint256 airstreamId) {
        asset.forceApprove(address(lockupDynamic), amount);

        airstreamId = lockupDynamic.createWithDeltas(
            LockupDynamic.CreateWithDeltas({
                asset: asset,
                broker: Broker({ account: address(0), fee: UD60x18.wrap(0) }),
                cancelable: cancelable,
                recipient: recipient,
                sender: admin,
                segments: segments,
                totalAmount: amount
            })
        );
    }
}
