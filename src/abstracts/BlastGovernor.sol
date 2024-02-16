// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.22;

import { Adminable } from "@sablier/v2-core/src/abstracts/Adminable.sol";

import { IBlast } from "../interfaces/IBlast.sol";
import { IBlastGovernor } from "../interfaces/IBlastGovernor.sol";

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
        IBlast(0x4300000000000000000000000000000000000002).configure(
            IBlast.YieldMode.VOID, IBlast.GasMode.CLAIMABLE, admin
        );

        // Configure USDB and WETH with automatic yield, admin can claim anytime using `clawback`.
        if (asset == 0x4200000000000000000000000000000000000022 || asset == 0x4200000000000000000000000000000000000023)
        {
            IBlast(asset).configure(IBlast.YieldMode.AUTOMATIC);
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IBlastGovernor
    function getClaimableAmount(IBlast token) external view override returns (uint256 claimableYield) {
        return token.getClaimableAmount(address(this));
    }

    /// @inheritdoc IBlastGovernor
    function readClaimableYield(IBlast blastEthAddress) external view override returns (uint256) {
        return blastEthAddress.readClaimableYield(address(this));
    }

    /// @inheritdoc IBlastGovernor
    function readGasParams(IBlast blastEthAddress)
        external
        view
        override
        returns (uint256 etherSeconds, uint256 etherBalance, uint256 lastUpdated, IBlast.GasMode gasMode)
    {
        return blastEthAddress.readGasParams(address(this));
    }

    /// @inheritdoc IBlastGovernor
    function readYieldConfiguration(IBlast blastEthAddress) external view override returns (uint8) {
        return blastEthAddress.readYieldConfiguration(address(this));
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IBlastGovernor
    function claim(
        uint256 amount,
        address recipientOfYield,
        IBlast token
    )
        external
        override
        onlyAdmin
        returns (uint256)
    {
        return token.claim(recipientOfYield, amount);
    }

    /// @inheritdoc IBlastGovernor
    function claimAllGas(
        IBlast blastEthAddress,
        address recipientOfGas
    )
        external
        override
        onlyAdmin
        returns (uint256)
    {
        return blastEthAddress.claimAllGas(address(this), recipientOfGas);
    }

    /// @inheritdoc IBlastGovernor
    function claimAllYield(
        IBlast blastEthAddress,
        address recipientOfYield
    )
        external
        override
        onlyAdmin
        returns (uint256)
    {
        return blastEthAddress.claimAllYield(address(this), recipientOfYield);
    }

    /// @inheritdoc IBlastGovernor
    function configure(IBlast token, IBlast.YieldMode yieldMode) external override onlyAdmin {
        token.configure({ yieldMode: yieldMode });
    }

    /// @inheritdoc IBlastGovernor
    function configure(
        IBlast blastEthAddress,
        IBlast.GasMode gasMode,
        IBlast.YieldMode yieldMode,
        address governor
    )
        external
        override
        onlyAdmin
    {
        blastEthAddress.configure({ yieldMode: yieldMode, gasMode: gasMode, governor: governor });
    }
}
