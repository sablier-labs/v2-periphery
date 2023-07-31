// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Adminable } from "@sablier/v2-core/abstracts/Adminable.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";

import { SablierV2Airstream } from "./abstracts/SablierV2Airstream.sol";
import { ISablierV2Airstream } from "./interfaces/ISablierV2Airstream.sol";
import { ISablierV2AirstreamLockupLinear } from "./interfaces/ISablierV2AirstreamLockupLinear.sol";

contract AirstreamLockupLinear is
    Adminable, // 1 inherit component
    ISablierV2AirstreamLockupLinear, // 2 inherited components
    SablierV2Airstream // 2 inherited components
{
    /*//////////////////////////////////////////////////////////////////////////
                               USER-FACING CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2AirstreamLockupLinear
    uint40 public immutable override duration;

    /// @inheritdoc ISablierV2AirstreamLockupLinear
    ISablierV2LockupLinear public immutable override lockupLinear;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Constructs the contract by initializing the immutable state variables.
    constructor(
        IERC20 asset_,
        bytes32 root_,
        bool cancelable_,
        uint40 expiration_,
        ISablierV2LockupLinear lockupLinear_,
        uint40 duration_
    )
        SablierV2Airstream(lockupLinear_, asset_, root_, cancelable_, expiration_)
    {
        lockupLinear = lockupLinear_;
        duration = duration_;
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2Airstream
    function claim(
        address recipient,
        uint128 amount,
        bytes32[] calldata merkleProof
    )
        external
        pure
        override
        returns (uint256 airstreamId)
    {
        recipient;
        amount;
        merkleProof;
        airstreamId = 0;
    }
}
