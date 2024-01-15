// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Errors as V2CoreErrors } from "@sablier/v2-core/src/libraries/Errors.sol";

import { Errors } from "src/libraries/Errors.sol";

import { MerkleLockup_Integration_Test } from "../../MerkleLockup.t.sol";

contract Clawback_Integration_Test is MerkleLockup_Integration_Test {
    function setUp() public virtual override {
        MerkleLockup_Integration_Test.setUp();
    }

    function test_RevertWhen_CallerNotAdmin() external {
        changePrank({ msgSender: users.eve });
        vm.expectRevert(abi.encodeWithSelector(V2CoreErrors.CallerNotAdmin.selector, users.admin, users.eve));
        merkleLockupLL.clawback({ to: users.eve, amount: 1 });
    }

    modifier whenCallerAdmin() {
        changePrank({ msgSender: users.admin });
        _;
    }

    function test_RevertGiven_CampaignNotExpired() external whenCallerAdmin {
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierV2MerkleLockup_CampaignNotExpired.selector, block.timestamp, defaults.EXPIRATION()
            )
        );
        merkleLockupLL.clawback({ to: users.admin, amount: 1 });
    }

    modifier givenCampaignExpired() {
        // Make a claim to have a different contract balance.
        claimLL();
        vm.warp({ timestamp: defaults.EXPIRATION() + 1 seconds });
        _;
    }

    function test_Clawback() external whenCallerAdmin givenCampaignExpired {
        test_Clawback(users.admin);
    }

    function testFuzz_Clawback(address to) external whenCallerAdmin givenCampaignExpired {
        vm.assume(to != address(0));
        test_Clawback(to);
    }

    function test_Clawback(address to) internal {
        uint128 clawbackAmount = uint128(asset.balanceOf(address(merkleLockupLL)));
        expectCallToTransfer({ to: to, amount: clawbackAmount });
        vm.expectEmit({ emitter: address(merkleLockupLL) });
        emit Clawback({ admin: users.admin, to: to, amount: clawbackAmount });
        merkleLockupLL.clawback({ to: to, amount: clawbackAmount });
    }
}
