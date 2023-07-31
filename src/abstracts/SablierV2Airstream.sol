// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ISablierV2Lockup } from "@sablier/v2-core/interfaces/ISablierV2Lockup.sol";

import { ISablierV2Airstream } from "../interfaces/ISablierV2Airstream.sol";

abstract contract SablierV2Airstream is ISablierV2Airstream {
    /*//////////////////////////////////////////////////////////////////////////
                               USER-FACING CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2Airstream
    IERC20 public immutable override asset;

    /// @inheritdoc ISablierV2Airstream
    bool public immutable override cancelable;

    /// @inheritdoc ISablierV2Airstream
    uint40 public immutable override expiration;

    /// @inheritdoc ISablierV2Airstream
    bytes32 public immutable override root;

    /*//////////////////////////////////////////////////////////////////////////
                                 INTERNAL CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev The address of the {SablierV2Lockup} contract.
    ISablierV2Lockup internal immutable lockup;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Constructs the contract by initializing the immutable state variables.
    constructor(ISablierV2Lockup lockup_, IERC20 asset_, bytes32 root_, bool cancelable_, uint40 expiration_) {
        lockup = lockup_;
        asset = asset_;
        root = root_;
        cancelable = cancelable_;
        expiration = expiration_;
    }

    /*//////////////////////////////////////////////////////////////////////////
                           USER-FACING CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2Airstream
    function hasClaimed(address recipient) external pure override returns (bool) {
        recipient;
        return false;
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2Airstream
    function cancel(uint256 airstreamId) external pure override {
        airstreamId;
    }

    /// @inheritdoc ISablierV2Airstream
    function cancelMultiple(uint256[] calldata airstreamIds) external pure override {
        airstreamIds;
    }

    /// @inheritdoc ISablierV2Airstream
    function clawback(uint128 amount) external pure override {
        amount;
    }
}
