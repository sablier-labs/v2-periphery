// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ISablierV2LockupDynamic } from "@sablier/v2-core/interfaces/ISablierV2LockupDynamic.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";
import { LockupDynamic, LockupLinear } from "@sablier/v2-core/types/DataTypes.sol";

import { ISablierV2AirstreamCampaignFactory } from "./interfaces/ISablierV2AirstreamCampaignFactory.sol";
import { ISablierV2AirstreamCampaign } from "./interfaces/ISablierV2AirstreamCampaign.sol";
import { ISablierV2AirstreamCampaignLD } from "./interfaces/ISablierV2AirstreamCampaignLD.sol";
import { ISablierV2AirstreamCampaignLL } from "./interfaces/ISablierV2AirstreamCampaignLL.sol";
import { SablierV2AirstreamCampaignLD } from "./SablierV2AirstreamCampaignLD.sol";
import { SablierV2AirstreamCampaignLL } from "./SablierV2AirstreamCampaignLL.sol";

contract SablierV2AirstreamCampaignFactory is ISablierV2AirstreamCampaignFactory {
    /*//////////////////////////////////////////////////////////////////////////
                                  INTERNAL STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    // question: should we rename `user` to `admin`?
    /// @notice The list of airstream campaigns created by the user.
    mapping(address user => ISablierV2AirstreamCampaign[] contracts) private _airstreamCampaigns;

    /*//////////////////////////////////////////////////////////////////////////
                           USER-FACING CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice inheritdoc ISablierV2AirstreamCampaignFactory
    function getAirstreamCampaigns(address user)
        external
        view
        override
        returns (ISablierV2AirstreamCampaign[] memory campaigns)
    {
        campaigns = _airstreamCampaigns[user];
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice inheritdoc ISablierV2AirstreamCampaignFactory
    function createAirstreamCampaignLD(
        address initialAdmin,
        IERC20 asset,
        bytes32 merkleRoot,
        bool cancelable,
        uint40 expiration,
        ISablierV2LockupDynamic lockupDynamic,
        LockupDynamic.SegmentWithDelta[] memory segments,
        string memory ipfsCID,
        uint256 campaignTotalAmount,
        uint256 recipientsCount
    )
        external
        returns (ISablierV2AirstreamCampaignLD airstreamCampaign)
    {
        // question: What value should the salt have?
        // Hash the common variables between campaigns to generate a salt.
        bytes32 salt = keccak256(abi.encodePacked(initialAdmin, asset, merkleRoot, cancelable, expiration));

        // Deploy the airstream campaign with CREATE2.
        airstreamCampaign = new SablierV2AirstreamCampaignLD{salt: salt} (
            initialAdmin,
            asset,
            merkleRoot,
            cancelable,
            expiration,
            lockupDynamic,
            segments
        );

        // Effects: store the campaign in the user's list of campaigns.
        _airstreamCampaigns[initialAdmin].push(airstreamCampaign);

        // Log the creation of the campaign.
        emit CreateAirstreamCampaignLD(
            initialAdmin, asset, airstreamCampaign, ipfsCID, campaignTotalAmount, recipientsCount
        );
    }

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
        // question: What value should the salt have?
        // Hash the common variables between campaigns to generate a salt.
        bytes32 salt = keccak256(abi.encodePacked(initialAdmin, asset, merkleRoot, cancelable, expiration));

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

        // Effects: store the campaign in the user's list of campaigns.
        _airstreamCampaigns[initialAdmin].push(airstreamCampaign);

        // Log the creation of the campaign.
        emit CreateAirstreamCampaignLL(
            initialAdmin, asset, airstreamCampaign, ipfsCID, campaignTotalAmount, recipientsCount
        );
    }
}
