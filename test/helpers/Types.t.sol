// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { StdCheats } from "forge-std/StdCheats.sol";

struct Users {
    StdCheats.Account admin;
    StdCheats.Account broker;
    StdCheats.Account recipient;
    StdCheats.Account sender;
}
