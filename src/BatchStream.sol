// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.18;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";
import { ISablierV2LockupPro } from "@sablier/v2-core/interfaces/ISablierV2LockupPro.sol";

import { IBatchStream } from "./interfaces/IBatchStream.sol";
import { Helpers } from "./libraries/Helpers.sol";
import { CreateLinear, CreatePro } from "./types/DataTypes.sol";

contract BatchStream is IBatchStream {
    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IBatchStream
    function createWithDeltasMultiple(
        ISablierV2LockupPro pro,
        CreatePro.DeltasParams[] calldata params,
        IERC20 asset,
        uint128 totalAmount
    ) external override returns (uint256[] memory streamIds) {
        uint128 amountsSum;
        uint256 count = params.length;
        uint256 i;

        // Calculate the params amounts summed up.
        for (i = 0; i < count; ) {
            amountsSum += params[i].amount;
            unchecked {
                i += 1;
            }
        }

        // Checks: validate the arguments.
        Helpers.checkCreateMultipleParams(count, totalAmount, amountsSum);

        // Interactions: perform the ERC-20 transfer and approve the sablier contract to spend the amount of assets.
        Helpers.transferAndApprove(address(pro), asset, totalAmount);

        for (i = 0; i < count; ) {
            // Interactions: make the external call without reverting if it fails at a certain index.
            streamIds[i] = Helpers.callCreateWithDeltas(params[i], asset, pro);

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
        }
    }

    /// @inheritdoc IBatchStream
    function createWithDurationsMultiple(
        ISablierV2LockupLinear linear,
        CreateLinear.DurationsParams[] calldata params,
        IERC20 asset,
        uint128 totalAmount
    ) external override returns (uint256[] memory streamIds) {
        uint128 amountsSum;
        uint256 count = params.length;
        uint256 i;

        // Calculate the params amounts summed up.
        for (i = 0; i < count; ) {
            amountsSum += params[i].amount;
            unchecked {
                i += 1;
            }
        }

        // Checks: validate the arguments.
        Helpers.checkCreateMultipleParams(count, totalAmount, amountsSum);

        // Interactions: perform the ERC-20 transfer and approve the sablier contract to spend the amount of assets.
        Helpers.transferAndApprove(address(linear), asset, totalAmount);

        for (i = 0; i < count; ) {
            // Interactions: make the external call without reverting if it fails at a certain index.
            streamIds[i] = Helpers.callCreateWithDurations(params[i], asset, linear);

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
        }
    }

    /// @inheritdoc IBatchStream
    function createWithMilestonesMultiple(
        ISablierV2LockupPro pro,
        CreatePro.MilestonesParams[] calldata params,
        IERC20 asset,
        uint128 totalAmount
    ) external override returns (uint256[] memory streamIds) {
        uint128 amountsSum;
        uint256 count = params.length;
        uint256 i;

        // Calculate the params amounts summed up.
        for (i = 0; i < count; ) {
            amountsSum += params[i].amount;
            unchecked {
                i += 1;
            }
        }

        // Checks: validate the arguments.
        Helpers.checkCreateMultipleParams(count, totalAmount, amountsSum);

        // Interactions: perform the ERC-20 transfer and approve the sablier contract to spend the amount of assets.
        Helpers.transferAndApprove(address(pro), asset, totalAmount);

        for (i = 0; i < count; ) {
            // Interactions: make the external call without reverting if it fails at a certain index.
            streamIds[i] = Helpers.callCreateWithMilestones(params[i], asset, pro);

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
        }
    }

    /// @inheritdoc IBatchStream
    function createWithRangeMultiple(
        ISablierV2LockupLinear linear,
        CreateLinear.RangeParams[] calldata params,
        IERC20 asset,
        uint128 totalAmount
    ) external override returns (uint256[] memory streamIds) {
        uint128 amountsSum;
        uint256 count = params.length;
        uint256 i;

        // Calculate the params amounts summed up.
        for (i = 0; i < count; ) {
            amountsSum += params[i].amount;
            unchecked {
                i += 1;
            }
        }

        // Checks: validate the arguments.
        Helpers.checkCreateMultipleParams(count, totalAmount, amountsSum);

        // Interactions: perform the ERC-20 transfer and approve the sablier contract to spend the amount of assets.
        Helpers.transferAndApprove(address(linear), asset, totalAmount);

        for (i = 0; i < count; ) {
            // Interactions: make the external call without reverting if it fails at a certain index.
            streamIds[i] = Helpers.callCreateWithRange(params[i], asset, linear);

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
        }
    }
}
