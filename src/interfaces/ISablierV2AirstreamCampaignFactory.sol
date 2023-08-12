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

    event CreateAirstreamCampaignLD(
        address indexed admin, bytes32 merkleRoot, ISablierV2AirstreamCampaignLD indexed airstream
    );
    event CreateAirstreamCampaignLL(
        address indexed admin, bytes32 merkleRoot, ISablierV2AirstreamCampaignLL indexed airstream
    );

    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Returns the list of airstream campaigns created by the user.
    function getAirstreamCampaigns(address user) external view returns (ISablierV2AirstreamCampaign[] memory);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Creates a new Sablier V2 Lockup Dynamic airstream campaign.
    function createAirstreamCampaignLD(
        address initialAdmin,
        IERC20 asset,
        bytes32 merkleRoot,
        bool cancelable,
        uint40 expiration,
        ISablierV2LockupDynamic lockupDynamic,
        LockupDynamic.SegmentWithDelta[] memory segments
    )
        external
        returns (ISablierV2AirstreamCampaignLD);

    /// @notice Creates a new Sablier V2 Lockup Linear airstream campaign.
    function createAirstreamCampaignLL(
        address initialAdmin,
        IERC20 asset,
        bytes32 merkleRoot,
        bool cancelable,
        uint40 expiration,
        ISablierV2LockupLinear lockupLinear,
        LockupLinear.Durations memory durations
    )
        external
        returns (ISablierV2AirstreamCampaignLL);
}
