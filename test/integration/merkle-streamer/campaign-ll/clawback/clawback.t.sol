// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Errors as V2CoreErrors } from "@sablier/v2-core/src/libraries/Errors.sol";

import { Errors } from "src/libraries/Errors.sol";

import { MerkleStreamer_Integration_Test } from "../../MerkleStreamer.t.sol";

contract Clawback_Integration_Test is MerkleStreamer_Integration_Test {
    function setUp() public virtual override {
        MerkleStreamer_Integration_Test.setUp();
    }

    function test_RevertWhen_CallerNotAdmin() external {
        changePrank({ msgSender: users.eve.addr });
        vm.expectRevert(abi.encodeWithSelector(V2CoreErrors.CallerNotAdmin.selector, users.admin.addr, users.eve.addr));
        merkleStreamerLL.clawback({ to: users.eve.addr, amount: 1 });
    }

    modifier whenCallerAdmin() {
        changePrank({ msgSender: users.admin.addr });
        _;
    }

    function test_RevertWhen_CampaignNotExpired() external whenCallerAdmin {
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierV2MerkleStreamer_CampaignNotExpired.selector, block.timestamp, defaults.EXPIRATION()
            )
        );
        merkleStreamerLL.clawback({ to: users.admin.addr, amount: 1 });
    }

    modifier givenCampaignExpired() {
        _;
    }

    function testFuzz_Clawback(address to) external whenCallerAdmin givenCampaignExpired {
        vm.assume(to != address(0));
        claimLL();
        uint128 clawbackAmount = uint128(asset.balanceOf(address(merkleStreamerLL)));
        expectCallToTransfer({ to: to, amount: clawbackAmount });
        vm.warp({ timestamp: defaults.EXPIRATION() + 1 seconds });
        vm.expectEmit({ emitter: address(merkleStreamerLL) });
        emit Clawback({ admin: users.admin.addr, to: to, amount: clawbackAmount });
        merkleStreamerLL.clawback({ to: to, amount: clawbackAmount });
    }
}
