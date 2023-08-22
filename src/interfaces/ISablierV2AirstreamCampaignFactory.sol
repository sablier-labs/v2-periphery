// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { ISablierV2AirstreamCampaignLL } from "./ISablierV2AirstreamCampaignLL.sol";

/// @title ISablierV2AirstreamCampaignFactory
/// @notice Deploys new Lockup Linear airstream campaigns via CREATE2 and stores them in the admin's list of campaigns.
interface ISablierV2AirstreamCampaignFactory {
    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a Sablier V2 Lockup Linear airstream campaign is created.
    event CreateAirstreamCampaignLL(
        address indexed admin,
        IERC20 indexed asset,
        ISablierV2AirstreamCampaignLL airstreamCampaign,
        string ipfsCID,
        uint256 campaignTotalAmount,
        uint256 recipientsCount
    );

    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Returns the list of airstream campaigns created by the admin.
    function getAirstreamCampaigns(address admin)
        external
        view
        returns (ISablierV2AirstreamCampaignLL[] memory airstreamCampaigns);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Creates a new Sablier V2 Lockup Linear airstream campaign.
    /// @dev Emits a {CreateAirstreamCampaignLL} event.
    /// @param initialAdmin The initial admin of the campaign.
    /// @param asset The asset of the campaign.
    /// @param merkleRoot The Merkle root of the campaign.
    /// @param cancelable Whether the airstreams are cancelable.
    /// @param expiration The expiration of the campaign.
    /// @param lockupLinear The address of the {SablierV2LockupLinear} contract.
    /// @param airstreamDurations The airstream durations of the campaign.
    /// @param ipfsCID Helper parameter to emit for additional information.
    /// @param campaignTotalAmount Helper parameter to emit for additional information.
    /// @param recipientsCount Helper parameter to emit for additional information.
    /// @return airstreamCampaignLL The address of the newly created airstream campaign.
    function createAirstreamCampaignLL(
        address initialAdmin,
        IERC20 asset,
        bytes32 merkleRoot,
        bool cancelable,
        uint40 expiration,
        ISablierV2LockupLinear lockupLinear,
        LockupLinear.Durations memory airstreamDurations,
        string memory ipfsCID,
        uint256 campaignTotalAmount,
        uint256 recipientsCount
    )
        external
        returns (ISablierV2AirstreamCampaignLL airstreamCampaignLL);
}
