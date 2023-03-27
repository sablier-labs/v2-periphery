// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ERC20 } from "@openzeppelin/token/ERC20/ERC20.sol";

import { IWETH9 } from "src/interfaces/IWETH9.sol";

contract WETH9 is IWETH9, ERC20("Wrapped Ether", "WETH9") {
    function deposit() public payable virtual {
        _mint(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public virtual {
        _burn(msg.sender, amount);
        payable(msg.sender).transfer(amount);
    }

    receive() external payable virtual {
        deposit();
    }
}
