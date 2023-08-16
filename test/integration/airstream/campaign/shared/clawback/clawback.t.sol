// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Errors as V2CoreErrors } from "@sablier/v2-core/libraries/Errors.sol";

import { Errors } from "src/libraries/Errors.sol";

import { Integration_Test } from "../../../../Integration.t.sol";

abstract contract Clawback_Integration_Test is Integration_Test {
    function setUp() public virtual override {
        changePrank({ msgSender: users.admin.addr });
    }

    function test_RevertWhen_CallerNotAdmin() external {
        changePrank({ msgSender: users.eve.addr });
        vm.expectRevert(abi.encodeWithSelector(V2CoreErrors.CallerNotAdmin.selector, users.admin, users.eve));
        campaign.clawback({ to: users.eve.addr, amount: 1 });
    }

    function test_RevertWhen_CampaignHasNotExpired() external {
        vm.expectRevert(
            abi.encodeWithSelector(Errors.SablierV2AirstreamCampaign_CampaignNotExpired.selector, defaults.EXPIRATION())
        );
        campaign.clawback({ to: users.admin.addr, amount: 1 });
    }
}
