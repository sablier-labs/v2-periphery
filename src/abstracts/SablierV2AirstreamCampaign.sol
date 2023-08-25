// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { Adminable } from "@sablier/v2-core/src/abstracts/Adminable.sol";

import { ISablierV2AirstreamCampaign } from "../interfaces/ISablierV2AirstreamCampaign.sol";
import { Errors } from "../libraries/Errors.sol";

/// @title SablierV2AirstreamCampaign
/// @notice See the documentation in {ISablierV2AirstreamCampaign}.
abstract contract SablierV2AirstreamCampaign is
    ISablierV2AirstreamCampaign, // 2 inherited component
    Adminable // 1 inherited component
{
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

    /// @dev Packed booleans that stores if a claim is available.
    mapping(uint256 wordIndex => uint256 packedBooleans) private _claimedBitMap;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Constructs the contract by initializing the immutable state variables.
    constructor(address initialAdmin, IERC20 asset_, bytes32 merkleRoot_, bool cancelable_, uint40 expiration_) {
        admin = initialAdmin;
        asset = asset_;
        merkleRoot = merkleRoot_;
        cancelable = cancelable_;
        expiration = expiration_;
    }

    /*//////////////////////////////////////////////////////////////////////////
                           USER-FACING CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2AirstreamCampaign
    /// @dev Uses a 256-bit word to represent 256 claims, where each bit corresponds to a claim.
    /// The `index` is divided into two parts: the word index and the bit index within the word.
    /// The word index determines which 256-bit word in the mapping is used, and the bit index identifies the specific
    /// bit within that word.
    /// A mask is formed with the bit index, and the result of a bitwise AND between the word and the mask will reveal
    /// if the bit is set.
    function hasClaimed(uint256 index) public view override returns (bool) {
        // The word index identifies the specific 256-bit word in the mapping.
        // Shifting 8 bits to the right means using the bits at positions [255:8].
        uint256 claimedWordIndex = index >> 8;

        // The bit index identifies the specific bit within the 256-bit word.
        // Applying an 8-bit mask means using the bits at positions [7:0].
        uint256 claimedBitIndex = index & 0xff;

        // Retrieves the 256-bit word from the mapping, representing the claimed statuses for 256 claims.
        uint256 claimedWord = _claimedBitMap[claimedWordIndex];

        // Creates a mask with a single bit set at the position specified by `claimedBitIndex`.
        uint256 mask = (1 << claimedBitIndex);

        // Uses the mask to extract the specific bit from the word and checks if it is set.
        return claimedWord & mask != 0;
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
            revert Errors.SablierV2AirstreamCampaign_CampaignHasNotExpired(block.timestamp, expiration);
        }

        asset.safeTransfer(to, amount);
        emit Clawback(admin, to, amount);
    }

    /*//////////////////////////////////////////////////////////////////////////
                            INTERNAL CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Validates the `claim` function which is meant to be implemented by the child contracts.
    function _checkClaim(uint256 index, bytes32 leaf, bytes32[] calldata merkleProof) internal view {
        // Checks: the campaign has not expired.
        if (hasExpired()) {
            revert Errors.SablierV2AirstreamCampaign_CampaignHasExpired(block.timestamp, expiration);
        }

        // Checks: the index has not been claimed.
        if (hasClaimed(index)) {
            revert Errors.SablierV2AirstreamCampaign_AlreadyClaimed(index);
        }

        // Checks: the input claim is included in the merkle tree.
        if (!MerkleProof.verify(merkleProof, merkleRoot, leaf)) {
            revert Errors.SablierV2AirstreamCampaign_InvalidProof();
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                          INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Marks a claim as made for a given index.
    /// @dev Similar to `hasClaimed`, this function divides the `index` into a word index and a bit index.
    /// It then uses these to form a mask and performs a bitwise OR between the mask and the current word to set the
    /// specific bit.
    /// @param index The index of the recipient to be marked as made.
    function _setClaimed(uint256 index) internal {
        // The word index identifies the specific 256-bit word in the mapping.
        // Shifting 8 bits to the right means using the bits at positions [255:8].
        uint256 claimedWordIndex = index >> 8;

        // The bit index identifies the specific bit within the 256-bit word.
        // Applying an 8-bit mask means using the bits at positions [7:0].
        uint256 claimedBitIndex = index & 0xff;

        // Sets the specific bit without altering the others in the word, marking the claim as made.
        _claimedBitMap[claimedWordIndex] = _claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }
}
