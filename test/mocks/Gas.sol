// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IGas, GasMode } from "@sablier/v2-core/src/interfaces/Blast/IGas.sol";

contract Gas is IGas {
    function readGasParams(address contractAddress)
        external
        view
        returns (uint256 etherSeconds, uint256 etherBalance, uint256 lastUpdated, GasMode gasMode)
    { }

    function claim(
        address contractAddress,
        address recipient,
        uint256 gasToClaim,
        uint256 gasSecondsToConsume
    )
        external
        returns (uint256)
    { }

    function claimAll(address contractAddress, address recipient) external returns (uint256) { }

    function claimGasAtMinClaimRate(
        address contractAddress,
        address recipient,
        uint256 minClaimRateBips
    )
        external
        returns (uint256)
    { }

    function claimMax(address contractAddress, address recipient) external returns (uint256) { }

    function setGasMode(address contractAddress, GasMode mode) external { }
}
