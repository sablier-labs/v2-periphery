// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { Broker, LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";
import { ud60x18 } from "@sablier/v2-core/src/types/Math.sol";

import { SablierV2MerkleStreamer } from "./abstracts/SablierV2MerkleStreamer.sol";
import { ISablierV2MerkleStreamerLL } from "./interfaces/ISablierV2MerkleStreamerLL.sol";

/// @title SablierV2MerkleStreamerLL
/// @notice See the documentation in {ISablierV2MerkleStreamerLL}.
contract SablierV2MerkleStreamerLL is
    ISablierV2MerkleStreamerLL, // 2 inherited components
    SablierV2MerkleStreamer // 4 inherited components
{
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////////////////
                               USER-FACING CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2MerkleStreamerLL
    ISablierV2LockupLinear public immutable override lockupLinear;

    /*//////////////////////////////////////////////////////////////////////////
                                USER-FACING STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2MerkleStreamerLL
    LockupLinear.Durations public override streamDurations;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Constructs the contract by initializing the immutable state variables, and max approving the Sablier
    /// contract.
    constructor(
        address initialAdmin,
        ISablierV2LockupLinear lockupLinear_,
        IERC20 asset_,
        bytes32 merkleRoot_,
        uint40 expiration_,
        LockupLinear.Durations memory streamDurations_,
        bool cancelable_
    )
        SablierV2MerkleStreamer(initialAdmin, asset_, merkleRoot_, expiration_, cancelable_)
    {
        lockupLinear = lockupLinear_;
        streamDurations = streamDurations_;

        // Max approve the Sablier contract to spend funds from the Merkle streamer.
        asset.forceApprove(address(lockupLinear), type(uint256).max);
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2MerkleStreamerLL
    function claim(
        uint256 index,
        address recipient,
        uint128 amount,
        bytes32[] calldata merkleProof
    )
        external
        override
        returns (uint256 streamId)
    {
        // Generate the Merkle tree leaf by hashing the corresponding parameters.
        bytes32 leaf = keccak256(abi.encodePacked(index, recipient, amount));

        // Checks: validate the function.
        _checkClaim(index, leaf, merkleProof);

        // Effects: mark the index as claimed.
        _setClaimed(index);

        // Interactions: create the stream via {SablierV2LockupLinear}.
        streamId = lockupLinear.createWithDurations(
            LockupLinear.CreateWithDurations({
                asset: asset,
                broker: Broker({ account: address(0), fee: ud60x18(0) }),
                cancelable: cancelable,
                durations: streamDurations,
                recipient: recipient,
                sender: admin,
                totalAmount: amount
            })
        );

        // Log the claim.
        emit Claim(index, recipient, amount, streamId);
    }
}
