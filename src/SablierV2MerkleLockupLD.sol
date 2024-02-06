// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { BitMaps } from "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ISablierV2LockupDynamic } from "@sablier/v2-core/src/interfaces/ISablierV2LockupDynamic.sol";
import { Broker, LockupDynamic } from "@sablier/v2-core/src/types/DataTypes.sol";
import { ud } from "@prb/math/src/UD60x18.sol";

import { SablierV2MerkleLockup } from "./abstracts/SablierV2MerkleLockup.sol";
import { ISablierV2MerkleLockupLD } from "./interfaces/ISablierV2MerkleLockupLD.sol";
import { MerkleLockup } from "./types/DataTypes.sol";

/// @title SablierV2MerkleLockupLD
/// @notice See the documentation in {ISablierV2MerkleLockupLD}.
contract SablierV2MerkleLockupLD is
    ISablierV2MerkleLockupLD, // 2 inherited components
    SablierV2MerkleLockup // 4 inherited components
{
    using BitMaps for BitMaps.BitMap;
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2MerkleLockupLD
    ISablierV2LockupDynamic public immutable override LOCKUP_DYNAMIC;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Constructs the contract by initializing the immutable state variables, and max approving the Sablier
    /// contract.
    constructor(
        MerkleLockup.ConstructorParams memory baseParams,
        ISablierV2LockupDynamic lockupDynamic
    )
        SablierV2MerkleLockup(baseParams)
    {
        LOCKUP_DYNAMIC = lockupDynamic;

        // Max approve the Sablier contract to spend funds from the Merkle Lockup contract.
        ASSET.forceApprove(address(LOCKUP_DYNAMIC), type(uint256).max);
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2MerkleLockupLD
    function claim(
        uint256 index,
        address recipient,
        uint128 amount,
        LockupDynamic.SegmentWithDuration[] memory segments,
        bytes32[] calldata merkleProof
    )
        external
        override
        returns (uint256 streamId)
    {
        // Generate the Merkle tree leaf by hashing the corresponding parameters. Hashing twice prevents second
        // preimage attacks.
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(index, recipient, amount, segments))));

        // Checks: validate the function.
        _checkClaim(index, leaf, merkleProof);

        // Effects: mark the index as claimed.
        _claimedBitMap.set(index);

        // Interactions: create the stream via {SablierV2LockupDynamic}.
        streamId = LOCKUP_DYNAMIC.createWithDurations(
            LockupDynamic.CreateWithDurations({
                sender: admin,
                recipient: recipient,
                totalAmount: amount,
                asset: ASSET,
                cancelable: CANCELABLE,
                transferable: TRANSFERABLE,
                segments: segments,
                broker: Broker({ account: address(0), fee: ud(0) })
            })
        );

        // Log the claim.
        emit Claim(index, recipient, amount, streamId);
    }
}
