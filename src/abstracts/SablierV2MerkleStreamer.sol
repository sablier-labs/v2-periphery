// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { BitMaps } from "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import { Adminable } from "@sablier/v2-core/src/abstracts/Adminable.sol";
import { ISablierV2Lockup } from "@sablier/v2-core/src/interfaces/ISablierV2Lockup.sol";
import { UD60x18, ud } from "@prb/math/src/UD60x18.sol";

import { ISablierV2MerkleStreamer } from "../interfaces/ISablierV2MerkleStreamer.sol";
import { Errors } from "../libraries/Errors.sol";

/// @title SablierV2MerkleStreamer
/// @notice See the documentation in {ISablierV2MerkleStreamer}.
abstract contract SablierV2MerkleStreamer is
    ISablierV2MerkleStreamer, // 2 inherited component
    Adminable // 1 inherited component
{
    using BitMaps for BitMaps.BitMap;
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////////////////
                               USER-FACING CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2MerkleStreamer
    IERC20 public immutable override ASSET;

    /// @inheritdoc ISablierV2MerkleStreamer
    bool public immutable override CANCELABLE;

    /// @inheritdoc ISablierV2MerkleStreamer
    uint40 public immutable override EXPIRATION;

    /// @inheritdoc ISablierV2MerkleStreamer
    ISablierV2Lockup public immutable override LOCKUP;

    /// @inheritdoc ISablierV2MerkleStreamer
    bytes32 public immutable override MERKLE_ROOT;

    /// @inheritdoc ISablierV2MerkleStreamer
    bool public immutable override TRANSFERABLE;

    /*//////////////////////////////////////////////////////////////////////////
                                  INTERNAL STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Packed booleans that record the history of claims.
    BitMaps.BitMap internal _claimedBitMap;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Constructs the contract by initializing the immutable state variables.
    constructor(
        address initialAdmin,
        IERC20 asset,
        ISablierV2Lockup lockup,
        bytes32 merkleRoot,
        uint40 expiration,
        bool cancelable,
        bool transferable
    ) {
        admin = initialAdmin;
        ASSET = asset;
        LOCKUP = lockup;
        MERKLE_ROOT = merkleRoot;
        EXPIRATION = expiration;
        CANCELABLE = cancelable;
        TRANSFERABLE = transferable;
    }

    /*//////////////////////////////////////////////////////////////////////////
                           USER-FACING CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2MerkleStreamer
    function hasClaimed(uint256 index) public view override returns (bool) {
        return _claimedBitMap.get(index);
    }

    /// @inheritdoc ISablierV2MerkleStreamer
    function hasExpired() public view override returns (bool) {
        return EXPIRATION > 0 && EXPIRATION <= block.timestamp;
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2MerkleStreamer
    function clawback(address to, uint128 amount) external override onlyAdmin {
        // Safe Interactions: query the protocol fee. This is safe because it's a known Sablier contract that does
        // not call other unknown contracts.
        UD60x18 protocolFee = LOCKUP.comptroller().protocolFees(ASSET);

        // Checks: the campaign is not expired and the protocol fee is zero.
        if (!hasExpired() && !protocolFee.gt(ud(0))) {
            revert Errors.SablierV2MerkleStreamer_CampaignNotExpired({
                currentTime: block.timestamp,
                expiration: EXPIRATION
            });
        }

        // Effects: transfer the tokens to the provided address.
        ASSET.safeTransfer(to, amount);

        // Log the clawback.
        emit Clawback(admin, to, amount);
    }

    /*//////////////////////////////////////////////////////////////////////////
                            INTERNAL CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Validates the parameters of the `claim` function, which is implemented by child contracts.
    function _checkClaim(uint256 index, bytes32 leaf, bytes32[] calldata merkleProof) internal view {
        // Checks: the campaign has not expired.
        if (hasExpired()) {
            revert Errors.SablierV2MerkleStreamer_CampaignExpired({
                currentTime: block.timestamp,
                expiration: EXPIRATION
            });
        }

        // Checks: the index has not been claimed.
        if (_claimedBitMap.get(index)) {
            revert Errors.SablierV2MerkleStreamer_StreamClaimed(index);
        }

        // Checks: the input claim is included in the Merkle tree.
        if (!MerkleProof.verify(merkleProof, MERKLE_ROOT, leaf)) {
            revert Errors.SablierV2MerkleStreamer_InvalidProof();
        }

        // Safe Interactions: query the protocol fee. This is safe because it's a known Sablier contract that does
        // not call other unknown contracts.
        UD60x18 protocolFee = LOCKUP.comptroller().protocolFees(ASSET);

        // Checks: the protocol fee is zero.
        if (protocolFee.gt(ud(0))) {
            revert Errors.SablierV2MerkleStreamer_ProtocolFeeNotZero();
        }
    }
}
