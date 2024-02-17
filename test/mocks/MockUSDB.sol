// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { ERC20Rebasing } from "./ERC20Rebasing.sol";

contract MockUSDB is ERC20Rebasing {
    uint256 public price = 1e8;

    constructor() ERC20Rebasing("Rebase USD coin", "USDB", 18) { }

    function sharePrice() public view override returns (uint256) {
        return price;
    }
}
