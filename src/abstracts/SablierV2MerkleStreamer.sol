// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { BitMaps } from "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import { Adminable } from "@sablier/v2-core/src/abstracts/Adminable.sol";

import { ISablierV2MerkleStreamer } from "../interfaces/ISablierV2MerkleStreamer.sol";
import { MerkleStreamer } from "../types/DataTypes.sol";
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
    bytes32 public immutable override MERKLE_ROOT;

    /// @inheritdoc ISablierV2MerkleStreamer
    bool public immutable override TRANSFERABLE;

    /*//////////////////////////////////////////////////////////////////////////
                                  PRIVATE CONSTANT
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev The name of the campaign stored as bytes32.
    bytes32 private immutable _NAME;

    /*//////////////////////////////////////////////////////////////////////////
                                  INTERNAL STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Packed booleans that record the history of claims.
    BitMaps.BitMap internal _claimedBitMap;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Constructs the contract by initializing the immutable state variables.
    constructor(MerkleStreamer.ConstructorParams memory params) {
        // Checks: the campaign name is not greater than 32 bytes
        if (bytes(params.name).length > 32) {
            revert Errors.SablierV2MerkleStreamer_CampaignNameTooLong({
                nameLength: bytes(params.name).length,
                maxLength: 32
            });
        }

        admin = params.initialAdmin;
        ASSET = params.asset;
        _NAME = bytes32(abi.encodePacked(params.name));
        MERKLE_ROOT = params.merkleRoot;
        EXPIRATION = params.expiration;
        CANCELABLE = params.cancelable;
        TRANSFERABLE = params.transferable;
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

    /// @inheritdoc ISablierV2MerkleStreamer
    function name() external view override returns (string memory) {
        return string(abi.encodePacked(_NAME));
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2MerkleStreamer
    function clawback(address to, uint128 amount) external override onlyAdmin {
        // Checks: the campaign is not expired.
        if (!hasExpired()) {
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
    }
}
