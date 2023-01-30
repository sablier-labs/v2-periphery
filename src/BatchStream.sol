// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.13;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";
import { ISablierV2LockupPro } from "@sablier/v2-core/interfaces/ISablierV2LockupPro.sol";

import { IBatchStream } from "./interfaces/IBatchStream.sol";
import { CreateLinear } from "./types/DataTypes.sol";
import { CreatePro } from "./types/DataTypes.sol";

abstract contract BatchStream is IBatchStream {
    using SafeERC20 for IERC20;

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
        CreateLinear.RangeParams[] memory params,
        IERC20 asset,
        uint128 totalDepositAmount
    ) external override returns (uint256[] memory streamIds) {
        /* uint128[] memory grossDepositAmount = params[].grossDepositAmount;
        // Checks: the total deposit amount is equal to the gross amounts summed up.
        _checkTotalDepositAmount(grossDepositAmount, totalDepositAmount); */

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

        // Interactions: perform the ERC-20 transfer.
        asset.safeTransferFrom({ from: msg.sender, to: address(this), value: totalDepositAmount });

        // Interactions: approve the Sablier linear to spend total deposit amount.
        asset.safeApprove({ spender: address(linear), value: totalDepositAmount });

        // uint256 count = params.length;

        for (i = 0; i < count; ) {
            // Interactions: make the external call without reverting if it fails at a certain index.
            try
                linear.createWithRange(
                    params[i].sender,
                    params[i].recipient,
                    params[i].grossDepositAmount,
                    asset,
                    params[i].cancelable,
                    params[i].range,
                    params[i].broker
                )
            returns (uint256 streamId) {
                streamIds[i] = streamId;
            } catch {}

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
        }
    }

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
