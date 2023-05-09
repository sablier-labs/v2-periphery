// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { Adminable } from "@sablier/v2-core/abstracts/Adminable.sol";

import { ISablierV2ChainLog } from "./interfaces/ISablierV2ChainLog.sol";

/*

███████╗ █████╗ ██████╗ ██╗     ██╗███████╗██████╗     ██╗   ██╗██████╗
██╔════╝██╔══██╗██╔══██╗██║     ██║██╔════╝██╔══██╗    ██║   ██║╚════██╗
███████╗███████║██████╔╝██║     ██║█████╗  ██████╔╝    ██║   ██║ █████╔╝
╚════██║██╔══██║██╔══██╗██║     ██║██╔══╝  ██╔══██╗    ╚██╗ ██╔╝██╔═══╝
███████║██║  ██║██████╔╝███████╗██║███████╗██║  ██║     ╚████╔╝ ███████╗
╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝╚══════╝╚═╝  ╚═╝      ╚═══╝  ╚══════╝

 ██████╗██╗  ██╗ █████╗ ██╗███╗   ██╗    ██╗      ██████╗  ██████╗
██╔════╝██║  ██║██╔══██╗██║████╗  ██║    ██║     ██╔═══██╗██╔════╝
██║     ███████║███████║██║██╔██╗ ██║    ██║     ██║   ██║██║  ███╗
██║     ██╔══██║██╔══██║██║██║╚██╗██║    ██║     ██║   ██║██║   ██║
╚██████╗██║  ██║██║  ██║██║██║ ╚████║    ███████╗╚██████╔╝╚██████╔╝
 ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝    ╚══════╝ ╚═════╝  ╚═════╝

*/

/// @title SablierV2ChainLog
/// @dev See the documentation in {ISablierV2ChainLog}.
contract SablierV2ChainLog is
    ISablierV2ChainLog, // 1 inherited component
    Adminable // 1 inherited component
{
    /*//////////////////////////////////////////////////////////////////////////
                                USER-FACING STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2ChainLog
    mapping(address addr => bool listed) public override isListed;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor(address initialAdmin) {
        admin = initialAdmin;
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2ChainLog
    function list(address addr) external onlyAdmin {
        isListed[addr] = true;
        emit List({ admin: msg.sender, addr: addr });
    }

    /// @inheritdoc ISablierV2ChainLog
    function unlist(address addr) external onlyAdmin {
        isListed[addr] = false;
        emit Unlist({ admin: msg.sender, addr: addr });
    }
}
