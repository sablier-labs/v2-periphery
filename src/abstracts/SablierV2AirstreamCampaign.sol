// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { Adminable } from "@sablier/v2-core/abstracts/Adminable.sol";

import { ISablierV2AirstreamCampaign } from "../interfaces/ISablierV2AirstreamCampaign.sol";
import { Errors } from "../libraries/Errors.sol";

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
                                     MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Reverts if the campaign has expired.
    modifier hasNotExpired() {
        if (block.timestamp > expiration) {
            revert Errors.SablierV2AirstreamCampaign_CampaignExpired(expiration);
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                           USER-FACING CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2AirstreamCampaign
    function hasClaimed(uint256 index) public view override returns (bool) {
        uint256 claimedWordIndex = index >> 8;
        uint256 claimedBitIndex = index & 0xff;
        uint256 claimedWord = _claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask != 0;
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2AirstreamCampaign
    function claim(
        uint256 index,
        address recipient,
        uint128 amount,
        bytes32[] calldata merkleProof
    )
        external
        override
        hasNotExpired
        returns (uint256 airstreamId)
    {
        // Checks: the index is unclaimed.
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

        airstreamId = _createAirstream(recipient, amount);

        emit Claim(index, recipient, amount, airstreamId);
    }

    /// @inheritdoc ISablierV2AirstreamCampaign
    function clawback(address to, uint128 amount) external override onlyAdmin hasNotExpired {
        asset.safeTransfer(to, amount);
        emit Clawback(admin, to, amount);
    }

    /*//////////////////////////////////////////////////////////////////////////
                          INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    // I think bad naming, might be confused with factory create functions?
    // question: How should we name this?
    // idea: What about renaming the factory related functions with "campaign"? e.g. createAirstreamCampaignLockupDynamic
    function _createAirstream(address recipient, uint128 amount) internal virtual returns (uint256 airstreamId);

    /// @notice Mark the provided index as having been claimed.
    /// @param index The index that is going to be claimed.
    function _setClaimed(uint256 index) internal {
        uint256 claimedWordIndex = index >> 8;
        uint256 claimedBitIndex = index & 0xff;
        _claimedBitMap[claimedWordIndex] = _claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }
}
