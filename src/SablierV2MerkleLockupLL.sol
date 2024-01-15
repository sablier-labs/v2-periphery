// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { BitMaps } from "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { Broker, LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";
import { ud } from "@prb/math/src/UD60x18.sol";

import { SablierV2MerkleLockup } from "./abstracts/SablierV2MerkleLockup.sol";
import { ISablierV2MerkleLockupLL } from "./interfaces/ISablierV2MerkleLockupLL.sol";
import { MerkleLockup } from "./types/DataTypes.sol";

/// @title SablierV2MerkleLockupLL
/// @notice See the documentation in {ISablierV2MerkleLockupLL}.
contract SablierV2MerkleLockupLL is
    ISablierV2MerkleLockupLL, // 2 inherited components
    SablierV2MerkleLockup // 4 inherited components
{
    using BitMaps for BitMaps.BitMap;
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2MerkleLockupLL
    ISablierV2LockupLinear public immutable override LOCKUP_LINEAR;

    /// @inheritdoc ISablierV2MerkleLockupLL
    LockupLinear.Durations public override streamDurations;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Constructs the contract by initializing the immutable state variables, and max approving the Sablier
    /// contract.
    constructor(
        MerkleLockup.ConstructorParams memory baseParams,
        ISablierV2LockupLinear lockupLinear,
        LockupLinear.Durations memory streamDurations_
    )
        SablierV2MerkleLockup(baseParams)
    {
        LOCKUP_LINEAR = lockupLinear;
        streamDurations = streamDurations_;

        // Max approve the Sablier contract to spend funds from the Merkle Lockup contract.
        ASSET.forceApprove(address(LOCKUP_LINEAR), type(uint256).max);
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2MerkleLockupLL
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
                sender: admin,
                recipient: recipient,
                totalAmount: amount,
                asset: ASSET,
                cancelable: CANCELABLE,
                transferable: TRANSFERABLE,
                durations: streamDurations,
                broker: Broker({ account: address(0), fee: ud(0) })
            })
        );

        // Log the claim.
        emit Claim(index, recipient, amount, streamId);
    }
}
