// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Errors as V2CoreErrors } from "@sablier/v2-core/src/libraries/Errors.sol";
import { ud } from "@prb/math/src/UD60x18.sol";

import { Errors } from "src/libraries/Errors.sol";

import { MerkleStreamer_Integration_Test } from "../../MerkleStreamer.t.sol";

contract Clawback_Integration_Test is MerkleStreamer_Integration_Test {
    function setUp() public virtual override {
        MerkleStreamer_Integration_Test.setUp();
    }

    function test_RevertWhen_CallerNotAdmin() external {
        changePrank({ msgSender: users.eve });
        vm.expectRevert(abi.encodeWithSelector(V2CoreErrors.CallerNotAdmin.selector, users.admin, users.eve));
        merkleStreamerLL.clawback({ to: users.eve, amount: 1 });
    }

    modifier whenCallerAdmin() {
        changePrank({ msgSender: users.admin });
        _;
    }

    modifier givenProtocolFeeZero() {
        _;
    }

    function test_RevertGiven_CampaignNotExpired() external whenCallerAdmin givenProtocolFeeZero {
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierV2MerkleStreamer_CampaignNotExpired.selector, block.timestamp, defaults.EXPIRATION()
            )
        );
        merkleStreamerLL.clawback({ to: users.admin, amount: 1 });
    }

    modifier givenCampaignExpired() {
        // Make a claim to have a different contract balance.
        claimLL();
        vm.warp({ timestamp: defaults.EXPIRATION() + 1 seconds });
        _;
    }

    function test_Clawback() external whenCallerAdmin givenProtocolFeeZero givenCampaignExpired {
        test_Clawback(users.admin);
    }

    modifier givenProtocolFeeNotZero() {
        comptroller.setProtocolFee({ asset: asset, newProtocolFee: ud(0.03e18) });
        _;
    }

    function testFuzz_Clawback_CampaignNotExpired(address to) external whenCallerAdmin givenProtocolFeeNotZero {
        vm.assume(to != address(0));
        test_Clawback(to);
    }

    function testFuzz_Clawback(address to) external whenCallerAdmin givenCampaignExpired givenProtocolFeeNotZero {
        vm.assume(to != address(0));
        test_Clawback(to);
    }

    function test_Clawback(address to) internal {
        uint128 clawbackAmount = uint128(asset.balanceOf(address(merkleStreamerLL)));
        expectCallToTransfer({ to: to, amount: clawbackAmount });
        vm.expectEmit({ emitter: address(merkleStreamerLL) });
        emit Clawback({ admin: users.admin, to: to, amount: clawbackAmount });
        merkleStreamerLL.clawback({ to: to, amount: clawbackAmount });
    }
}
