// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ISablierV2LockupDynamic } from "@sablier/v2-core/interfaces/ISablierV2LockupDynamic.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";
import { LockupDynamic, LockupLinear } from "@sablier/v2-core/types/DataTypes.sol";

import { ISablierV2AirstreamCampaignFactory } from "./interfaces/ISablierV2AirstreamCampaignFactory.sol";
import { ISablierV2AirstreamCampaignLD } from "./interfaces/ISablierV2AirstreamCampaignLD.sol";
import { ISablierV2AirstreamCampaignLL } from "./interfaces/ISablierV2AirstreamCampaignLL.sol";
import { Errors } from "./libraries/Errors.sol";
import { SablierV2AirstreamCampaignLD } from "./SablierV2AirstreamCampaignLD.sol";
import { SablierV2AirstreamCampaignLL } from "./SablierV2AirstreamCampaignLL.sol";

contract SablierV2AirstreamCampaignFactory is ISablierV2AirstreamCampaignFactory {
    /*//////////////////////////////////////////////////////////////////////////
                                  INTERNAL STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    // question: should we use mappings to store the airstream campaigns?
    // How should the mappings look like?
    mapping(
        address admin
            => mapping(
                IERC20 asset
                    => mapping(
                        bytes32 merkleRoot => mapping(uint40 expiration => ISablierV2AirstreamCampaignLD airstream)
                    )
            )
    ) private _lockupDynamicAirstreams;

    mapping(
        address admin
            => mapping(
                IERC20 asset
                    => mapping(
                        bytes32 merkleRoot => mapping(uint40 expiration => ISablierV2AirstreamCampaignLL airstream)
                    )
            )
    ) private _lockupLinearAirstreams;

    /*//////////////////////////////////////////////////////////////////////////
                           USER-FACING CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice inheritdoc ISablierV2AirstreamCampaignFactory
    function getAirstreamLockupDynamic(
        address admin,
        IERC20 asset,
        bytes32 merkleRoot,
        uint40 expiration
    )
        public
        view
        returns (ISablierV2AirstreamCampaignLD)
    {
        return _lockupDynamicAirstreams[admin][asset][merkleRoot][expiration];
    }

    /// @notice inheritdoc ISablierV2AirstreamCampaignFactory
    function getAirstreamLockupLinear(
        address admin,
        IERC20 asset,
        bytes32 merkleRoot,
        uint40 expiration
    )
        public
        view
        returns (ISablierV2AirstreamCampaignLL)
    {
        return _lockupLinearAirstreams[admin][asset][merkleRoot][expiration];
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice inheritdoc ISablierV2AirstreamCampaignFactory
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
        returns (ISablierV2AirstreamCampaignLD airstream)
    {
        if (
            getAirstreamLockupDynamic(initialAdmin, asset, merkleRoot, expiration)
                != ISablierV2AirstreamCampaignLD(address(0))
        ) {
            revert Errors.SablierV2AirstreamCampaignFactory_CampaignAlreadyDeployed(
                address(getAirstreamLockupDynamic(initialAdmin, asset, merkleRoot, expiration))
            );
        }

        bytes32 salt = keccak256(abi.encodePacked(initialAdmin, asset, merkleRoot, expiration));

        airstream = new SablierV2AirstreamCampaignLD{salt: salt} (
            initialAdmin,
            asset,
            merkleRoot,
            cancelable,
            expiration,
            lockupDynamic,
            segments
        );

        _lockupDynamicAirstreams[initialAdmin][asset][merkleRoot][expiration] = airstream;

        emit CreateAirstreamLockupDynamic(initialAdmin, merkleRoot, airstream);
    }

    /// @notice inheritdoc ISablierV2AirstreamCampaignFactory
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
        returns (ISablierV2AirstreamCampaignLL airstream)
    {
        if (
            getAirstreamLockupLinear(initialAdmin, asset, merkleRoot, expiration)
                != ISablierV2AirstreamCampaignLL(address(0))
        ) {
            revert Errors.SablierV2AirstreamCampaignFactory_CampaignAlreadyDeployed(
                address(getAirstreamLockupLinear(initialAdmin, asset, merkleRoot, expiration))
            );
        }

        bytes32 salt = keccak256(abi.encodePacked(initialAdmin, asset, merkleRoot, expiration));

        airstream = new SablierV2AirstreamCampaignLL{salt: salt} (
            initialAdmin,
            asset,
            merkleRoot,
            cancelable,
            expiration,
            lockupLinear,
            durations
        );

        _lockupLinearAirstreams[initialAdmin][asset][merkleRoot][expiration] = airstream;

        emit CreateAirstreamLockupLinear(initialAdmin, merkleRoot, airstream);
    }
}
