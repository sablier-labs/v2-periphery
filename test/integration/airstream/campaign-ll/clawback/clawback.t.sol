// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Errors as V2CoreErrors } from "@sablier/v2-core/src/libraries/Errors.sol";

import { Errors } from "src/libraries/Errors.sol";

import { Integration_Test } from "../../../Integration.t.sol";

contract Clawback_Integration_Test is Integration_Test {
    function setUp() public virtual override {
        Integration_Test.setUp();
    }

    function test_RevertWhen_CallerNotAdmin() external {
        changePrank({ msgSender: users.eve.addr });
        vm.expectRevert(abi.encodeWithSelector(V2CoreErrors.CallerNotAdmin.selector, users.admin.addr, users.eve.addr));
        campaignLL.clawback({ to: users.eve.addr, amount: 1 });
    }

    modifier whenCallerAdmin() {
        changePrank({ msgSender: users.admin.addr });
        _;
    }

    function test_RevertWhen_CampaignHasNotExpired() external whenCallerAdmin {
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierV2AirstreamCampaign_CampaignExpired.selector, block.timestamp, defaults.EXPIRATION()
            )
        );
        campaignLL.clawback({ to: users.admin.addr, amount: 1 });
    }

    modifier whenCampaignHasExpired() {
        _;
    }

    function test_Clawback() external whenCallerAdmin whenCampaignHasExpired {
        claimLL();
        uint128 clawbackAmount = uint128(asset.balanceOf(address(campaignLL)));
        vm.warp({ timestamp: defaults.EXPIRATION() + 1 });
        expectCallToTransfer({ to: users.admin.addr, amount: clawbackAmount });
        vm.expectEmit();
        emit Clawback({ admin: users.admin.addr, to: users.admin.addr, amount: clawbackAmount });
        campaignLL.clawback({ to: users.admin.addr, amount: clawbackAmount });
    }
}
