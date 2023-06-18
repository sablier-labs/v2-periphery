// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <0.9.0;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import { IWrappedNativeAsset } from "../../src/interfaces/IWrappedNativeAsset.sol";

contract WLC is IWrappedNativeAsset, ERC20("Wrapped Low Credit", "WLC") {
    receive() external payable virtual {
        deposit();
    }

    /// @dev Subtracts 1 wei from the deposit amount.
    function deposit() public payable virtual {
        _mint({ account: msg.sender, amount: msg.value - 1 wei });
    }

    function withdraw(uint256 amount) public virtual {
        _burn({ account: msg.sender, amount: amount });
        payable(msg.sender).transfer(amount);
    }
}
