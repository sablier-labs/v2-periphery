// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { ISablierV2AirstreamCampaignFactory } from "./interfaces/ISablierV2AirstreamCampaignFactory.sol";
import { ISablierV2AirstreamCampaignLL } from "./interfaces/ISablierV2AirstreamCampaignLL.sol";
import { SablierV2AirstreamCampaignLL } from "./SablierV2AirstreamCampaignLL.sol";

/// @title ISablierV2AirstreamCampaignFactory
/// @notice Deploys new Lockup Linear airstream campaigns via CREATE2 and stores them in the admin's list of campaigns.
contract SablierV2AirstreamCampaignFactory is ISablierV2AirstreamCampaignFactory {
    /*//////////////////////////////////////////////////////////////////////////
                                  INTERNAL STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice The list of airstream campaigns created by the admin.
    mapping(address admin => ISablierV2AirstreamCampaignLL[] contracts) private _airstreamCampaigns;

    /*//////////////////////////////////////////////////////////////////////////
                           USER-FACING CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice inheritdoc ISablierV2AirstreamCampaignFactory
    function getAirstreamCampaigns(address admin)
        external
        view
        override
        returns (ISablierV2AirstreamCampaignLL[] memory campaigns)
    {
        campaigns = _airstreamCampaigns[admin];
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice inheritdoc ISablierV2AirstreamCampaignFactory
    function createAirstreamCampaignLL(
        address initialAdmin,
        IERC20 asset,
        bytes32 merkleRoot,
        bool cancelable,
        uint40 expiration,
        ISablierV2LockupLinear lockupLinear,
        LockupLinear.Durations memory durations,
        string memory ipfsCID,
        uint256 campaignTotalAmount,
        uint256 recipientsCount
    )
        external
        returns (ISablierV2AirstreamCampaignLL airstreamCampaign)
    {
        // Hash some common variables between campaigns to generate a salt.
        bytes32 salt = keccak256(abi.encodePacked(initialAdmin, asset, merkleRoot, expiration));

        // Deploy the airstream campaign with CREATE2.
        airstreamCampaign = new SablierV2AirstreamCampaignLL{salt: salt} (
            initialAdmin,
            asset,
            merkleRoot,
            cancelable,
            expiration,
            lockupLinear,
            durations
        );

        // Effects: store the campaign in the admin's list of campaigns.
        _airstreamCampaigns[initialAdmin].push(airstreamCampaign);

        // Log the creation of the campaign.
        emit CreateAirstreamCampaignLL(
            initialAdmin, asset, airstreamCampaign, ipfsCID, campaignTotalAmount, recipientsCount
        );
    }
}
