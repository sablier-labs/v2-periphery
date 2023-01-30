// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.13;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";
import { ISablierV2LockupPro } from "@sablier/v2-core/interfaces/ISablierV2LockupPro.sol";

import { CreateLinear } from "../types/DataTypes.sol";
import { CreatePro } from "../types/DataTypes.sol";

interface IBatchStream {
    /*//////////////////////////////////////////////////////////////////////////
                                   CUSTOM ERRORS
    //////////////////////////////////////////////////////////////////////////*/
    error BatchStream_TotalDepositAmountNotEqualToGrossDepositAmountsSum(
        uint128 totalDeposit,
        uint128 grossDepositAmountsSum
    );

    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice The Sablier V2 Lockup Linear core contract.
    /// @return The contract address.
    function linear() external view returns (ISablierV2LockupLinear);

    /// @notice The Sablier V2 Lockup Pro core contract.
    /// @return The contract address.
    function pro() external view returns (ISablierV2LockupPro);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Creates multiple linear streams with range funded by `msg.sender`.
    function createWithRangeMultiple(
        CreateLinear.RangeParams[] calldata params,
        IERC20 asset,
        uint128 totalDepositAmount
    ) external returns (uint256[] memory streamIds);

    /// @notice Creates multiple pro streams with milestones funded by `msg.sender`.
    function createWithMilestonesMultiple(
        CreatePro.MilestonesParams[] calldata params,
        IERC20 asset,
        uint128 totalDepositAmount
    ) external returns (uint256[] memory streamIds);
}
