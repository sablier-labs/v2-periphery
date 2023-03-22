// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { UD2x18, ud2x18 } from "@prb/math/UD2x18.sol";
import { Broker, LockupDynamic } from "@sablier/v2-core/types/DataTypes.sol";

import { Batch, Permit2Params } from "src/types/DataTypes.sol";

import { Base_Test } from "../Base.t.sol";
import { DefaultParams } from "../helpers/DefaultParams.t.sol";

contract Unit_Test is Base_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                     VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    Permit2Params internal defaultPermit2Params;

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        Base_Test.setUp();

        // Deploy and label the sender proxy.
        proxy = registry.deployFor(users.sender);
        vm.label({ account: address(proxy), newLabel: "Proxy" });

        defaultPermit2Params = Permit2Params({
            permit2: permit2,
            expiration: DefaultParams.PERMIT2_EXPIRATION,
            sigDeadline: DefaultParams.PERMIT2_SIG_DEADLINE,
            signature: getPermit2Signature(privateKeys.sender, address(proxy))
        });

        deployCore();
        approvePermit2();
    }

    /*//////////////////////////////////////////////////////////////////////////
                          INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Creates default streams with deltas.
    function batchCreateWithDeltasDefault() internal returns (uint256[] memory streamIds) {
        bytes memory data = abi.encodeCall(
            target.batchCreateWithDeltas,
            (
                dynamic,
                asset,
                DefaultParams.TOTAL_AMOUNT,
                DefaultParams.batchCreateWithDeltas(users),
                defaultPermit2Params
            )
        );
        bytes memory response = proxy.execute(address(target), data);
        streamIds = abi.decode(response, (uint256[]));
    }

    /// @dev Creates default streams with durations.
    function batchCreateWithDurationsDefault() internal returns (uint256[] memory streamIds) {
        bytes memory data = abi.encodeCall(
            target.batchCreateWithDurations,
            (
                linear,
                asset,
                DefaultParams.TOTAL_AMOUNT,
                DefaultParams.batchCreateWithDurations(users),
                defaultPermit2Params
            )
        );
        bytes memory response = proxy.execute(address(target), data);
        streamIds = abi.decode(response, (uint256[]));
    }

    /// @dev Creates default streams with milestones.
    function batchCreateWithMilestonesDefault() internal returns (uint256[] memory streamIds) {
        bytes memory data = abi.encodeCall(
            target.batchCreateWithMilestones,
            (
                dynamic,
                asset,
                DefaultParams.TOTAL_AMOUNT,
                DefaultParams.batchCreateWithMilestones(users),
                defaultPermit2Params
            )
        );
        bytes memory response = proxy.execute(address(target), data);
        streamIds = abi.decode(response, (uint256[]));
    }

    /// @dev Creates default streams with range.
    function batchCreateWithRangeDefault() internal returns (uint256[] memory streamIds) {
        bytes memory data = abi.encodeCall(
            target.batchCreateWithRange,
            (linear, asset, DefaultParams.TOTAL_AMOUNT, DefaultParams.batchCreateWithRange(users), defaultPermit2Params)
        );
        bytes memory response = proxy.execute(address(target), data);
        streamIds = abi.decode(response, (uint256[]));
    }

    /// @dev Creates a default stream with deltas.
    function creteWithDeltasDefault() internal returns (uint256 streamId) {
        bytes memory data = abi.encodeCall(
            target.createWithDeltas, (dynamic, DefaultParams.createWithDeltas(users, asset), defaultPermit2Params)
        );
        bytes memory response = proxy.execute(address(target), data);
        streamId = abi.decode(response, (uint256));
    }

    /// @dev Creates a default stream with durations.
    function createWithDurationsDefault() internal returns (uint256 streamId) {
        bytes memory data = abi.encodeCall(
            target.createWithDurations, (linear, DefaultParams.createWithDurations(users, asset), defaultPermit2Params)
        );
        bytes memory response = proxy.execute(address(target), data);
        streamId = abi.decode(response, (uint256));
    }

    /// @dev Creates a default stream with milestones.
    function createWithMilestonesDefault() internal returns (uint256 streamId) {
        bytes memory data = abi.encodeCall(
            target.createWithMilestones,
            (dynamic, DefaultParams.createWithMilestones(users, asset), defaultPermit2Params)
        );
        bytes memory response = proxy.execute(address(target), data);
        streamId = abi.decode(response, (uint256));
    }

    /// @dev Creates a default stream with range.
    function createWithRangeDefault() internal returns (uint256 streamId) {
        bytes memory data = abi.encodeCall(
            target.createWithRange, (linear, DefaultParams.createWithRange(users, asset), defaultPermit2Params)
        );
        bytes memory response = proxy.execute(address(target), data);
        streamId = abi.decode(response, (uint256));
    }
}
