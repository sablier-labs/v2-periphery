// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { BitMaps } from "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import { Adminable } from "@sablier/v2-core/src/abstracts/Adminable.sol";

import { ISablierV2AirstreamCampaign } from "../interfaces/ISablierV2AirstreamCampaign.sol";
import { Errors } from "../libraries/Errors.sol";

/// @title SablierV2AirstreamCampaign
/// @notice See the documentation in {ISablierV2AirstreamCampaign}.
abstract contract SablierV2AirstreamCampaign is
    ISablierV2AirstreamCampaign, // 2 inherited component
    Adminable // 1 inherited component
{
    using BitMaps for BitMaps.BitMap;
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////////////////
                               USER-FACING CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2AirstreamCampaign
    IERC20 public immutable override asset;

    /// @inheritdoc ISablierV2AirstreamCampaign
    bool public immutable override cancelable;

    /// @inheritdoc ISablierV2AirstreamCampaign
    uint40 public immutable override expiration;

    /// @inheritdoc ISablierV2AirstreamCampaign
    bytes32 public immutable override merkleRoot;

    /*//////////////////////////////////////////////////////////////////////////
                                  INTERNAL STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Packed booleans that record the history of claims.
    BitMaps.BitMap private _claimedBitMap;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Constructs the contract by initializing the immutable state variables.
    constructor(address initialAdmin, IERC20 asset_, bytes32 merkleRoot_, uint40 expiration_, bool cancelable_) {
        admin = initialAdmin;
        asset = asset_;
        merkleRoot = merkleRoot_;
        expiration = expiration_;
        cancelable = cancelable_;
    }

    /*//////////////////////////////////////////////////////////////////////////
                           USER-FACING CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2AirstreamCampaign
    function hasClaimed(uint256 index) public view override returns (bool) {
        return _claimedBitMap.get(index);
    }

    /// @inheritdoc ISablierV2AirstreamCampaign
    function hasExpired() public view override returns (bool) {
        return expiration > 0 && expiration <= block.timestamp;
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2AirstreamCampaign
    function clawback(address to, uint128 amount) external override onlyAdmin {
        // Checks: the campaign has expired.
        if (!hasExpired()) {
            revert Errors.SablierV2AirstreamCampaign_CampaignExpired({
                currentTime: block.timestamp,
                expiration: expiration
            });
        }

        // Effects: transfer the tokens to the provided address.
        asset.safeTransfer(to, amount);

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
            revert Errors.SablierV2AirstreamCampaign_CampaignHasExpired({
                currentTime: block.timestamp,
                expiration: expiration
            });
        }

        // Checks: the index has not been claimed.
        if (_claimedBitMap.get(index)) {
            revert Errors.SablierV2AirstreamCampaign_AirstreamClaimed(index);
        }

        // Checks: the input claim is included in the Merkle tree.
        if (!MerkleProof.verify(merkleProof, merkleRoot, leaf)) {
            revert Errors.SablierV2AirstreamCampaign_InvalidProof();
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                          INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Marks an index as claimed in the bitmap.
    /// @param index The index of the recipient to mark as claimed.
    function _setClaimed(uint256 index) internal {
        _claimedBitMap.set(index);
    }
}
