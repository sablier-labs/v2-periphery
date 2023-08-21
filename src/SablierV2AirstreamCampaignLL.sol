// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { Broker, LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";
import { UD60x18 } from "@sablier/v2-core/src/types/Math.sol";

import { SablierV2AirstreamCampaign } from "./abstracts/SablierV2AirstreamCampaign.sol";
import { ISablierV2AirstreamCampaignLL } from "./interfaces/ISablierV2AirstreamCampaignLL.sol";
import { Errors } from "./libraries/Errors.sol";

/// @title SablierV2AirstreamCampaignLL
/// @notice See the documentation in {ISablierV2AirstreamCampaignLL}.
contract SablierV2AirstreamCampaignLL is
    ISablierV2AirstreamCampaignLL, // 2 inherited components
    SablierV2AirstreamCampaign // 4 inherited components
{
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////////////////
                               USER-FACING CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2AirstreamCampaignLL
    LockupLinear.Durations public override airstreamDurations;

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
        LockupLinear.Durations memory airstreamDurations_
    )
        SablierV2AirstreamCampaign(initialAdmin, asset_, merkleRoot_, cancelable_, expiration_)
    {
        lockupLinear = lockupLinear_;
        airstreamDurations = airstreamDurations_;

        // Approve the Sablier contract to spend funds from the airstream campaign.
        asset.forceApprove(address(lockupLinear), type(uint256).max);
    }

    /*//////////////////////////////////////////////////////////////////////////
                          INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2AirstreamCampaignLL
    function claim(
        uint256 index,
        address recipient,
        uint128 amount,
        bytes32[] calldata merkleProof
    )
        external
        override
        returns (uint256 airstreamId)
    {
        // Checks: the campaign has not expired.
        if (expiration > 0 && expiration <= block.timestamp) {
            revert Errors.SablierV2AirstreamCampaign_CampaignExpired(block.timestamp, expiration);
        }

        // Checks: the index is has been claimed.
        if (hasClaimed(index)) {
            revert Errors.SablierV2AirstreamCampaign_AlreadyClaimed(index);
        }

        // Hash the function arguments.
        bytes32 leaf = keccak256(abi.encodePacked(index, recipient, amount));

        // Checks: the input claim belongs to the unique merkle root.
        if (!MerkleProof.verify(merkleProof, merkleRoot, leaf)) {
            revert Errors.SablierV2AirstreamCampaign_InvalidProof();
        }

        // Effects: mark the index as claimed.
        _setClaimed(index);

        // Interactions: create the airstream on the {SablierV2LockupLinear} contract.
        airstreamId = lockupLinear.createWithDurations(
            LockupLinear.CreateWithDurations({
                asset: asset,
                broker: Broker({ account: address(0), fee: UD60x18.wrap(0) }),
                cancelable: cancelable,
                durations: airstreamDurations,
                recipient: recipient,
                sender: admin,
                totalAmount: amount
            })
        );

        // Log the claim.
        emit Claim(index, recipient, amount, airstreamId);
    }
}
