// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Adminable } from "@sablier/v2-core/abstracts/Adminable.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";
import { Broker, LockupLinear } from "@sablier/v2-core/types/DataTypes.sol";
import { UD60x18 } from "@sablier/v2-core/types/Math.sol";

import { SablierV2Airstream } from "./abstracts/SablierV2Airstream.sol";
import { ISablierV2Airstream } from "./interfaces/ISablierV2Airstream.sol";
import { ISablierV2AirstreamLockupLinear } from "./interfaces/ISablierV2AirstreamLockupLinear.sol";

contract SablierV2AirstreamLockupLinear is
    ISablierV2AirstreamLockupLinear, // 2 inherited components
    SablierV2Airstream // 4 inherited components
{
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////////////////
                               USER-FACING CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2AirstreamLockupLinear
    LockupLinear.Durations public override durations;

    /// @inheritdoc ISablierV2AirstreamLockupLinear
    ISablierV2LockupLinear public immutable override lockupLinear;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Constructs the contract by initializing the immutable state variables.
    constructor(
        address initialAdmin,
        IERC20 asset_,
        bytes32 merkleRoot_,
        bool cancelable_,
        uint40 expiration_,
        ISablierV2LockupLinear lockupLinear_,
        LockupLinear.Durations memory durations_
    )
        SablierV2Airstream(initialAdmin, asset_, merkleRoot_, cancelable_, expiration_)
    {
        lockupLinear = lockupLinear_;
        durations = durations_;
    }

    /*//////////////////////////////////////////////////////////////////////////
                          INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function _createAirstream(address recipient, uint128 amount) internal override returns (uint256 airstreamId) {
        // question: Should we add a global function to approve the contract once that can be called only by admin?
        asset.forceApprove(address(lockupLinear), amount);

        airstreamId = lockupLinear.createWithDurations(
            LockupLinear.CreateWithDurations({
                asset: asset,
                broker: Broker({ account: address(0), fee: UD60x18.wrap(0) }),
                cancelable: cancelable,
                durations: durations,
                recipient: recipient,
                sender: admin,
                totalAmount: amount
            })
        );
    }
}
