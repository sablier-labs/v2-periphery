// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { BitMaps } from "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { Broker, LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";
import { ud } from "@prb/math/src/UD60x18.sol";

import { SablierV2MerkleStreamer } from "./abstracts/SablierV2MerkleStreamer.sol";
import { ISablierV2MerkleStreamerLL } from "./interfaces/ISablierV2MerkleStreamerLL.sol";

/// @title SablierV2MerkleStreamerLL
/// @notice See the documentation in {ISablierV2MerkleStreamerLL}.
contract SablierV2MerkleStreamerLL is
    ISablierV2MerkleStreamerLL, // 2 inherited components
    SablierV2MerkleStreamer // 4 inherited components
{
    using BitMaps for BitMaps.BitMap;
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////////////////
                               USER-FACING CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2MerkleStreamerLL
    ISablierV2LockupLinear public immutable override LOCKUP_LINEAR;

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
        ISablierV2LockupLinear lockupLinear,
        IERC20 asset,
        bytes32 merkleRoot,
        uint40 expiration,
        LockupLinear.Durations memory streamDurations_,
        bool cancelable,
        bool transferable
    )
        SablierV2MerkleStreamer(initialAdmin, asset, lockupLinear, merkleRoot, expiration, cancelable, transferable)
    {
        LOCKUP_LINEAR = lockupLinear;
        streamDurations = streamDurations_;

        // Max approve the Sablier contract to spend funds from the Merkle streamer.
        ASSET.forceApprove(address(LOCKUP_LINEAR), type(uint256).max);
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
        // Generate the Merkle tree leaf by hashing the corresponding parameters. Hashing twice prevents second
        // preimage attacks.
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(index, recipient, amount))));

        // Checks: validate the function.
        _checkClaim(index, leaf, merkleProof);

        // Effects: mark the index as claimed.
        _claimedBitMap.set(index);

        // Interactions: create the stream via {SablierV2LockupLinear}.
        streamId = LOCKUP_LINEAR.createWithDurations(
            LockupLinear.CreateWithDurations({
                asset: ASSET,
                broker: Broker({ account: address(0), fee: ud(0) }),
                cancelable: CANCELABLE,
                durations: streamDurations,
                recipient: recipient,
                sender: admin,
                totalAmount: amount,
                transferable: TRANSFERABLE
            })
        );

        // Log the claim.
        emit Claim(index, recipient, amount, streamId);
    }
}
