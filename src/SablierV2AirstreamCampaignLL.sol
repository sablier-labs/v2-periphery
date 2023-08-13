// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";
import { Broker, LockupLinear } from "@sablier/v2-core/types/DataTypes.sol";
import { UD60x18 } from "@sablier/v2-core/types/Math.sol";

import { SablierV2AirstreamCampaign } from "./abstracts/SablierV2AirstreamCampaign.sol";
import { ISablierV2AirstreamCampaignLL } from "./interfaces/ISablierV2AirstreamCampaignLL.sol";

/// @title SablierV2AirstreamCampaignLD
contract SablierV2AirstreamCampaignLL is
    ISablierV2AirstreamCampaignLL, // 2 inherited components
    SablierV2AirstreamCampaign // 4 inherited components
{
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////////////////
                               USER-FACING CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2AirstreamCampaignLL
    LockupLinear.Durations public override durations;

    /// @inheritdoc ISablierV2AirstreamCampaignLL
    ISablierV2LockupLinear public immutable override lockupLinear;

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
        ISablierV2LockupLinear lockupLinear_,
        LockupLinear.Durations memory durations_
    )
        SablierV2AirstreamCampaign(initialAdmin, asset_, merkleRoot_, cancelable_, expiration_)
    {
        lockupLinear = lockupLinear_;
        durations = durations_;

        // Approve the Sablier contract to spend funds from the airstream campaign.
        asset.forceApprove(address(lockupLinear), type(uint256).max);
    }

    /*//////////////////////////////////////////////////////////////////////////
                          INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Creates an airstream on the {SablierV2LockupLinear} contract.
    function _createAirstream(address recipient, uint128 amount) internal override returns (uint256 airstreamId) {
        airstreamId = lockupLinear.createWithDurations(
            LockupLinear.CreateWithDurations({
                asset: asset,
                broker: Broker({ account: address(0), fee: UD60x18.wrap(0) }),
                cancelable: cancelable,
                durations: durations,
                recipient: recipient,
                sender: admin,
                totalAmount: amount
            })
        );
    }
}
