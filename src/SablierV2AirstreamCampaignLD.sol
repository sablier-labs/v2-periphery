// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ISablierV2LockupDynamic } from "@sablier/v2-core/interfaces/ISablierV2LockupDynamic.sol";
import { Broker, LockupDynamic } from "@sablier/v2-core/types/DataTypes.sol";
import { UD60x18 } from "@sablier/v2-core/types/Math.sol";

import { SablierV2AirstreamCampaign } from "./abstracts/SablierV2AirstreamCampaign.sol";
import { ISablierV2AirstreamCampaignLD } from "./interfaces/ISablierV2AirstreamCampaignLD.sol";

/// @title SablierV2AirstreamCampaignLD
contract SablierV2AirstreamCampaignLD is
    ISablierV2AirstreamCampaignLD, // 2 inherited components
    SablierV2AirstreamCampaign // 4 inherited components
{
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////////////////
                               USER-FACING CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2AirstreamCampaignLD
    ISablierV2LockupDynamic public immutable override lockupDynamic;

    /// @notice The array of segments needed for creating the LockupDynamic stream, which implicitly provides the total
    /// streaming duration of each airstream.
    LockupDynamic.SegmentWithDelta[] public segments;

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
        SablierV2AirstreamCampaign(initialAdmin, asset_, merkleRoot_, cancelable_, expiration_)
    {
        lockupDynamic = lockupDynamic_;
        uint256 length = segments_.length;
        for (uint256 i = 0; i < length;) {
            segments.push(segments_[i]);
            unchecked {
                i += 1;
            }
        }

        // Approve the Sablier contract to spend funds from the airstream campaign.
        asset.approve(address(lockupDynamic), type(uint256).max);
    }

    /*//////////////////////////////////////////////////////////////////////////
                           USER-FACING CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2AirstreamCampaignLD
    function getSegment(uint256 segmentIndex) external view returns (LockupDynamic.SegmentWithDelta memory) {
        return segments[segmentIndex];
    }

    /// @inheritdoc ISablierV2AirstreamCampaignLD
    function getSegments() external view returns (LockupDynamic.SegmentWithDelta[] memory) {
        return segments;
    }

    /*//////////////////////////////////////////////////////////////////////////
                          INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Creates an airstream on the {SablierV2LockupDynamic} contract.
    function _createAirstream(address recipient, uint128 amount) internal override returns (uint256 airstreamId) {
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
