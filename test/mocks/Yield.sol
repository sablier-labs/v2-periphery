// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IYield } from "@sablier/v2-core/src/interfaces/Blast/IYield.sol";

contract Yield is IYield {
    function getClaimableAmount(address contractAddress) external view returns (uint256 amount) { }

    function getConfiguration(address contractAddress) external view returns (uint8) { }

    function claim(
        address contractAddress,
        address recipientOfYield,
        uint256 desiredAmount
    )
        external
        returns (uint256)
    { }

    function configure(address contractAddress, uint8 flags) external returns (uint256) { }
}
