// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ISablierV2LockupDynamic } from "@sablier/v2-core/interfaces/ISablierV2LockupDynamic.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";
import { LockupDynamic, LockupLinear } from "@sablier/v2-core/types/DataTypes.sol";

import { ISablierV2AirstreamCampaign } from "./ISablierV2AirstreamCampaign.sol";
import { ISablierV2AirstreamCampaignLD } from "./ISablierV2AirstreamCampaignLD.sol";
import { ISablierV2AirstreamCampaignLL } from "./ISablierV2AirstreamCampaignLL.sol";

interface ISablierV2AirstreamCampaignFactory {
    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    // question: Maximum number of indexed params is 3, which should them?
    event CreateAirstreamCampaignLD(
        address indexed admin,
        IERC20 indexed asset,
        ISablierV2AirstreamCampaignLD indexed airstreamCampaign,
        string ipfsCID,
        uint256 campaignTotalAmount,
        uint256 recipientsCount
    );
    event CreateAirstreamCampaignLL(
        address indexed admin,
        IERC20 indexed asset,
        ISablierV2AirstreamCampaignLL indexed airstreamCampaign,
        string ipfsCID,
        uint256 campaignTotalAmount,
        uint256 recipientsCount
    );

    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Returns the list of airstream campaigns created by the admin.
    function getAirstreamCampaigns(address admin) external view returns (ISablierV2AirstreamCampaign[] memory);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Creates a new Sablier V2 Lockup Dynamic airstream campaign.
    /// @dev Emits a {CreateAirstreamCampaignLD} event.
    /// @param initialAdmin The initial admin of the campaign.
    /// @param asset The asset of the campaign.
    /// @param merkleRoot The Merkle root of the campaign.
    /// @param cancelable Whether the airstreams are cancelable.
    /// @param expiration The expiration of the campaign.
    /// @param lockupDynamic The address of the {SablierV2LockupDynamic} contract.
    /// @param segments The segments of the campaign.
    /// @param ipfsCID Helper parameter to emit for additional information.
    /// @param campaignTotalAmount Helper parameter to emit for additional information.
    /// @param recipientsCount Helper parameter to emit for additional information./
    /// @return airstreamCampaign The address of the newly created airstream campaign.
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
        returns (ISablierV2AirstreamCampaignLD airstreamCampaign);

    /// @notice Creates a new Sablier V2 Lockup Linear airstream campaign.
    /// @dev Emits a {CreateAirstreamCampaignLL} event.
    /// @param initialAdmin The initial admin of the campaign.
    /// @param asset The asset of the campaign.
    /// @param merkleRoot The Merkle root of the campaign.
    /// @param cancelable Whether the airstreams are cancelable.
    /// @param expiration The expiration of the campaign.
    /// @param lockupLinear The address of the {SablierV2LockupLinear} contract.
    /// @param durations The durations of the campaign.
    /// @param ipfsCID Helper parameter to emit for additional information.
    /// @param campaignTotalAmount Helper parameter to emit for additional information.
    /// @param recipientsCount Helper parameter to emit for additional information.
    /// @return airstreamCampaign The address of the newly created airstream campaign.
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
        returns (ISablierV2AirstreamCampaignLL airstreamCampaign);
}
