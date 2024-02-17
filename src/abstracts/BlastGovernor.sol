// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19;

import { Adminable } from "@sablier/v2-core/src/abstracts/Adminable.sol";
import { IERC20Rebasing } from "@sablier/v2-core/src/interfaces/Blast/IERC20Rebasing.sol";
import { IBlast } from "@sablier/v2-core/src/interfaces/Blast/IBlast.sol";
import { GasMode } from "@sablier/v2-core/src/interfaces/Blast/IGas.sol";
import { YieldMode } from "@sablier/v2-core/src/interfaces/Blast/IYield.sol";
import { IBlastGovernor } from "@sablier/v2-core/src/interfaces/IBlastGovernor.sol";

/// @title BlastGovernor
/// @notice This contract implements logic to interact with the Blast contracts.
/// @dev Deploys with default Disabled yield for ETH and Automatic yield for USDB and WETH (https://docs.blast.io)
///     - Blast ETH: 0x4300000000000000000000000000000000000002
///     - Blast USDB: 0x4200000000000000000000000000000000000022
///     - Blast WETH: 0x4200000000000000000000000000000000000023
abstract contract BlastGovernor is
    Adminable, // 1 inherited component
    IBlastGovernor // 0 inherited component
{
    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor(address asset) {
        // Configure ETH with void yield mode and claimabale gas mode.
        IBlast(0x4300000000000000000000000000000000000002).configure(YieldMode.VOID, GasMode.CLAIMABLE, admin);

        // Configure USDB and WETH with automatic yield, admin can claim anytime using `clawback`.
        if (asset == 0x4200000000000000000000000000000000000022 || asset == 0x4200000000000000000000000000000000000023)
        {
            IERC20Rebasing(asset).configure(YieldMode.AUTOMATIC);
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IBlastGovernor
    function getClaimableAmount(IERC20Rebasing token) external view override returns (uint256 claimableYield) {
        return token.getClaimableAmount(address(this));
    }

    /// @inheritdoc IBlastGovernor
    function getConfiguration(IERC20Rebasing token) external view override returns (YieldMode) {
        return token.getConfiguration(address(this));
    }

    /// @inheritdoc IBlastGovernor
    function readClaimableYield(IBlast blastEth) external view override returns (uint256) {
        return blastEth.readClaimableYield(address(this));
    }

    /// @inheritdoc IBlastGovernor
    function readGasParams(IBlast blastEth)
        external
        view
        override
        returns (uint256 etherSeconds, uint256 etherBalance, uint256 lastUpdated, GasMode gasMode)
    {
        return blastEth.readGasParams(address(this));
    }

    /// @inheritdoc IBlastGovernor
    function readYieldConfiguration(IBlast blastEth) external view override returns (uint8) {
        return blastEth.readYieldConfiguration(address(this));
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IBlastGovernor
    function claim(
        uint256 amount,
        address recipientOfYield,
        IERC20Rebasing token
    )
        external
        override
        onlyAdmin
        returns (uint256)
    {
        return token.claim(recipientOfYield, amount);
    }

    /// @inheritdoc IBlastGovernor
    function claimAllGas(IBlast blastEth, address recipientOfGas) external override onlyAdmin returns (uint256) {
        return blastEth.claimAllGas(address(this), recipientOfGas);
    }

    /// @inheritdoc IBlastGovernor
    function claimAllYield(IBlast blastEth, address recipientOfYield) external override onlyAdmin returns (uint256) {
        return blastEth.claimAllYield(address(this), recipientOfYield);
    }

    /// @inheritdoc IBlastGovernor
    function configureYieldForToken(
        IERC20Rebasing token,
        YieldMode yieldMode
    )
        external
        override
        onlyAdmin
        returns (uint256)
    {
        return token.configure(yieldMode);
    }

    /// @inheritdoc IBlastGovernor
    function configureVoidYieldAndClaimableGas(IBlast blastEth, address governor) external override onlyAdmin {
        blastEth.configure(YieldMode.VOID, GasMode.CLAIMABLE, governor);
    }
}
