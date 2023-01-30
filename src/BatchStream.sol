// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.13;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";
import { ISablierV2LockupPro } from "@sablier/v2-core/interfaces/ISablierV2LockupPro.sol";

import { IBatchStream } from "./interfaces/IBatchStream.sol";
import { Helpers } from "./libraries/Helpers.sol";
import { CreateLinear } from "./types/DataTypes.sol";
import { CreatePro } from "./types/DataTypes.sol";

contract BatchStream is IBatchStream {
    /*//////////////////////////////////////////////////////////////////////////
                                   PUBLIC STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IBatchStream
    ISablierV2LockupLinear public immutable override linear;

    /// @inheritdoc IBatchStream
    ISablierV2LockupPro public immutable override pro;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor(ISablierV2LockupLinear _linear, ISablierV2LockupPro _pro) {
        linear = _linear;
        pro = _pro;
    }

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IBatchStream
    function createWithRangeMultiple(
        CreateLinear.RangeParams[] calldata params,
        IERC20 asset,
        uint128 totalDepositAmount
    ) external override returns (uint256[] memory streamIds) {
        uint256 count = params.length;
        uint128 grossDepositAmountsSum;
        uint256 i;

        for (i = 0; i < count; ) {
            grossDepositAmountsSum += params[i].grossDepositAmount;
            unchecked {
                i += 1;
            }
        }

        if (grossDepositAmountsSum != totalDepositAmount) {
            revert BatchStream_TotalDepositAmountNotEqualToGrossDepositAmountsSum(
                totalDepositAmount,
                grossDepositAmountsSum
            );
        }

        // Interactions: perform the ERC-20 transfer and approve the sablier contract to spend the amount of assets.
        Helpers.transferAndApprove(address(linear), asset, totalDepositAmount);

        // uint256 count = params.length;

        for (i = 0; i < count; ) {
            // Interactions: make the external call without reverting if it fails at a certain index.
            streamIds[i] = Helpers.tryCreateWithRange(params[i], asset, linear);

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
        }
    }

    function createWithMilestonesMultiple(
        CreatePro.MilestoneParams[] calldata params,
        IERC20 asset,
        uint128 totalDepositAmount
    ) external override returns (uint256[] memory streamIds) {
        /* uint128[] memory grossDepositAmount = params[].grossDepositAmount;
        // Checks: the total deposit amount is equal to the gross amounts summed up.
        _checkTotalDepositAmount(grossDepositAmount, totalDepositAmount); */
        uint256 i;
        uint256 count = params.length;
        uint128 grossDepositAmountsSum;

        for (i = 0; i < count; ) {
            grossDepositAmountsSum += params[i].grossDepositAmount;
            unchecked {
                i += 1;
            }
        }

        if (grossDepositAmountsSum != totalDepositAmount) {
            revert BatchStream_TotalDepositAmountNotEqualToGrossDepositAmountsSum(
                totalDepositAmount,
                grossDepositAmountsSum
            );
        }

        // Interactions: perform the ERC-20 transfer and approve the sablier contract to spend the amount of assets.
        Helpers.transferAndApprove(address(pro), asset, totalDepositAmount);

        for (i = 0; i < count; ) {
            // Interactions: make the external call without reverting if it fails at a certain index.
            streamIds[i] = Helpers.tryCreateWithMilestones(params[i], asset, pro);

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                            INTERNAL CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Checks that the total deposit amount is equal to the gross deposit amounts summed up.
    function _checkTotalDepositAmount(uint128[] memory grossDepositAmount, uint128 totalDepositAmount) internal pure {
        uint256 count = grossDepositAmount.length;
        uint128 grossDepositAmountsSum;
        for (uint256 i = 0; i < count; ) {
            grossDepositAmountsSum += grossDepositAmount[i];
            unchecked {
                i += 1;
            }
        }

        if (grossDepositAmountsSum != totalDepositAmount) {
            revert BatchStream_TotalDepositAmountNotEqualToGrossDepositAmountsSum(
                totalDepositAmount,
                grossDepositAmountsSum
            );
        }
    }
}
