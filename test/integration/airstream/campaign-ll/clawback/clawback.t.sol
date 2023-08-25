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
                Errors.SablierV2AirstreamCampaign_CampaignHasNotExpired.selector, block.timestamp, defaults.EXPIRATION()
            )
        );
        campaignLL.clawback({ to: users.admin.addr, amount: 1 });
    }

    modifier whenCampaignHasExpired() {
        _;
    }

    function test_RevertWhen_AllClaimsMade() external whenCallerAdmin whenCampaignHasExpired {
        claimLL();
        campaignLL.claim(defaults.INDEX2(), users.recipient2.addr, defaults.CLAIMABLE_AMOUNT(), defaults.index2Proof());
        campaignLL.claim(defaults.INDEX3(), users.recipient3.addr, defaults.CLAIMABLE_AMOUNT(), defaults.index3Proof());
        campaignLL.claim(defaults.INDEX4(), users.recipient4.addr, defaults.CLAIMABLE_AMOUNT(), defaults.index4Proof());
        vm.warp({ timestamp: defaults.EXPIRATION() + 1 });
        vm.expectRevert();
        campaignLL.clawback({ to: users.admin.addr, amount: 1 });
    }

    modifier whenNotAllClaimsMade() {
        _;
    }

    function test_Clawback_NoClaims() external whenCallerAdmin whenCampaignHasExpired whenNotAllClaimsMade {
        testClawback();
    }

    function test_Clawback() external whenCallerAdmin whenCampaignHasExpired whenNotAllClaimsMade {
        claimLL();
        testClawback();
    }

    function testClawback() internal {
        uint128 clawbackAmount = uint128(asset.balanceOf(address(campaignLL)));
        vm.warp({ timestamp: defaults.EXPIRATION() + 1 });
        expectCallToTransfer({ to: users.admin.addr, amount: clawbackAmount });
        vm.expectEmit();
        emit Clawback(users.admin.addr, users.admin.addr, clawbackAmount);
        campaignLL.clawback({ to: users.admin.addr, amount: clawbackAmount });
    }
}
