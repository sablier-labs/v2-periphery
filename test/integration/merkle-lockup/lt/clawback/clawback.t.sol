// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Errors as V2CoreErrors } from "@sablier/v2-core/src/libraries/Errors.sol";

import { Errors } from "src/libraries/Errors.sol";

import { MerkleLockup_Integration_Test } from "../../MerkleLockup.t.sol";

contract Clawback_Integration_Test is MerkleLockup_Integration_Test {
    uint40 internal firstClaimTime;
    uint256 internal claimIndex = 1;

    function setUp() public virtual override {
        MerkleLockup_Integration_Test.setUp();
    }

    function test_RevertWhen_CallerNotAdmin() external {
        resetPrank({ msgSender: users.eve });
        vm.expectRevert(abi.encodeWithSelector(V2CoreErrors.CallerNotAdmin.selector, users.admin, users.eve));
        merkleLT.clawback({ to: users.eve, amount: 1 });
    }

    modifier whenCallerAdmin() {
        resetPrank({ msgSender: users.admin });
        _;
    }

    function test_Clawback_BeforeFirstClaim() external whenCallerAdmin {
        test_Clawback(users.admin);
    }

    modifier AfterFirstClaim() {
        // Make the first claim to set `_firstClaimTime`.
        claimLTAt(claimIndex++);
        firstClaimTime = uint40(block.timestamp);
        _;
    }

    function test_Clawback_GracePeriod() external whenCallerAdmin AfterFirstClaim {
        vm.warp({ newTimestamp: block.timestamp + 6 days });
        test_Clawback(users.admin);
    }

    modifier PostGracePeriod() {
        vm.warp({ newTimestamp: block.timestamp + 8 days });
        _;
    }

    function test_RevertGiven_CampaignNotExpired() external whenCallerAdmin AfterFirstClaim PostGracePeriod {
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierV2MerkleLockup_ClawbackNotAllowed.selector,
                block.timestamp,
                defaults.EXPIRATION(),
                firstClaimTime
            )
        );
        merkleLT.clawback({ to: users.admin, amount: 1 });
    }

    modifier givenCampaignExpired() {
        // Make a claim to have a different contract balance.
        claimLTAt(claimIndex++);
        vm.warp({ newTimestamp: defaults.EXPIRATION() + 1 seconds });
        _;
    }

    function test_Clawback() external whenCallerAdmin AfterFirstClaim PostGracePeriod givenCampaignExpired {
        test_Clawback(users.admin);
    }

    function testFuzz_Clawback(address to)
        external
        whenCallerAdmin
        AfterFirstClaim
        PostGracePeriod
        givenCampaignExpired
    {
        vm.assume(to != address(0));
        test_Clawback(to);
    }

    function test_Clawback(address to) internal {
        uint128 clawbackAmount = uint128(dai.balanceOf(address(merkleLT)));
        expectCallToTransfer({ to: to, amount: clawbackAmount });
        vm.expectEmit({ emitter: address(merkleLT) });
        emit Clawback({ admin: users.admin, to: to, amount: clawbackAmount });
        merkleLT.clawback({ to: to, amount: clawbackAmount });
    }
}
