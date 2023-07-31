// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Adminable } from "@sablier/v2-core/abstracts/Adminable.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";
import { LockupLinear } from "@sablier/v2-core/types/DataTypes.sol";

import { Airstream } from "./abstracts/Airstream.sol";
import { IAirstream } from "./interfaces/IAirstream.sol";
import { IAirstreamLockupLinear } from "./interfaces/IAirstreamLockupLinear.sol";

contract AirstreamLockupLinear is
    Adminable, // 1 inherit component
    IAirstreamLockupLinear, // 2 inherited components
    Airstream // 2 inherited components
{
    /*//////////////////////////////////////////////////////////////////////////
                               USER-FACING CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IAirstreamLockupLinear
    uint40 public immutable override duration;

    /// @inheritdoc IAirstreamLockupLinear
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
        Airstream(lockupLinear_, asset_, root_, cancelable_, expiration_)
    {
        lockupLinear = lockupLinear_;
        duration = duration_;
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IAirstream
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
