// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.13;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";
import { ISablierV2LockupPro } from "@sablier/v2-core/interfaces/ISablierV2LockupPro.sol";

import { IBatchStream } from "./interfaces/IBatchStream.sol";
import { Helpers } from "./libraries/Helpers.sol";
import { CreateLinear, CreatePro } from "./types/DataTypes.sol";

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

    /// @param _linear The address of the Sablier v2 linear core contract.
    /// @param _pro The address of the Sablier v2 pro core contract.
    constructor(ISablierV2LockupLinear _linear, ISablierV2LockupPro _pro) {
        linear = _linear;
        pro = _pro;
    }

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IBatchStream
    function createWithDeltasMultiple(
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
            streamIds[i] = Helpers.tryCreateWithDeltas(params[i], asset, pro);

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
        }
    }

    /// @inheritdoc IBatchStream
    function createWithDurationsMultiple(
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
            streamIds[i] = Helpers.tryCreateWithDurations(params[i], asset, linear);

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
        }
    }

    /// @inheritdoc IBatchStream
    function createWithMilestonesMultiple(
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
            streamIds[i] = Helpers.tryCreateWithMilestones(params[i], asset, pro);

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
        }
    }

    /// @inheritdoc IBatchStream
    function createWithRangeMultiple(
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
            streamIds[i] = Helpers.tryCreateWithRange(params[i], asset, linear);

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
        }
    }
}
