// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Permit2Params } from "src/types/DataTypes.sol";

import { Base_Test } from "../Base.t.sol";
import { DefaultParams } from "../helpers/DefaultParams.t.sol";

contract Unit_Test is Base_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        Base_Test.setUp();

        // Deploy and label the sender proxy.
        proxy = registry.deployFor(users.sender);
        vm.label({ account: address(proxy), newLabel: "Proxy" });

        deployCore();
        approvePermit2();
    }

    /*//////////////////////////////////////////////////////////////////////////
                            INTERNAL CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function permit2Params() internal view returns (Permit2Params memory) {
        return DefaultParams.permit2Params(
            permit2,
            getPermit2Signature(DefaultParams.permitDetails(address(asset)), privateKeys.sender, address(proxy))
        );
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
                DefaultParams.batchCreateWithDeltas(users, address(proxy)),
                DefaultParams.permit2Params(
                    permit2,
                    getPermit2Signature(DefaultParams.permitDetails(address(asset)), privateKeys.sender, address(proxy))
                    )
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
                DefaultParams.batchCreateWithDurations(users, address(proxy)),
                permit2Params()
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
                DefaultParams.batchCreateWithMilestones(users, address(proxy)),
                permit2Params()
            )
        );
        bytes memory response = proxy.execute(address(target), data);
        streamIds = abi.decode(response, (uint256[]));
    }

    /// @dev Creates default streams with range.
    function batchCreateWithRangeDefault() internal returns (uint256[] memory streamIds) {
        bytes memory data = abi.encodeCall(
            target.batchCreateWithRange,
            (
                linear,
                asset,
                DefaultParams.TOTAL_AMOUNT,
                DefaultParams.batchCreateWithRange(users, address(proxy)),
                permit2Params()
            )
        );
        bytes memory response = proxy.execute(address(target), data);
        streamIds = abi.decode(response, (uint256[]));
    }

    /// @dev Creates a default stream with deltas.
    function creteWithDeltasDefault() internal returns (uint256 streamId) {
        bytes memory data = abi.encodeCall(
            target.createWithDeltas,
            (dynamic, DefaultParams.createWithDeltas(users, address(proxy), asset), permit2Params())
        );
        bytes memory response = proxy.execute(address(target), data);
        streamId = abi.decode(response, (uint256));
    }

    /// @dev Creates a default stream with durations.
    function createWithDurationsDefault() internal returns (uint256 streamId) {
        bytes memory data = abi.encodeCall(
            target.createWithDurations,
            (linear, DefaultParams.createWithDurations(users, address(proxy), asset), permit2Params())
        );
        bytes memory response = proxy.execute(address(target), data);
        streamId = abi.decode(response, (uint256));
    }

    /// @dev Creates a default stream with milestones.
    function createWithMilestonesDefault() internal returns (uint256 streamId) {
        bytes memory data = abi.encodeCall(
            target.createWithMilestones,
            (dynamic, DefaultParams.createWithMilestones(users, address(proxy), asset), permit2Params())
        );
        bytes memory response = proxy.execute(address(target), data);
        streamId = abi.decode(response, (uint256));
    }

    /// @dev Creates a default stream with milestones given the `nonce`.
    function createWithMilestonesWithNonce(uint48 nonce) internal returns (uint256 streamId) {
        Permit2Params memory _permit2Params = Permit2Params({
            permit2: permit2,
            expiration: DefaultParams.PERMIT2_EXPIRATION,
            sigDeadline: DefaultParams.PERMIT2_SIG_DEADLINE,
            signature: getPermit2Signature(
                DefaultParams.permitDetailsWithNonce(address(asset), nonce), privateKeys.sender, address(proxy)
                )
        });

        bytes memory data = abi.encodeCall(
            target.createWithMilestones,
            (dynamic, DefaultParams.createWithMilestones(users, address(proxy), asset), _permit2Params)
        );
        bytes memory response = proxy.execute(address(target), data);
        streamId = abi.decode(response, (uint256));
    }

    /// @dev Creates a default stream with range.
    function createWithRangeDefault() internal returns (uint256 streamId) {
        bytes memory data = abi.encodeCall(
            target.createWithRange,
            (linear, DefaultParams.createWithRange(users, address(proxy), asset), permit2Params())
        );
        bytes memory response = proxy.execute(address(target), data);
        streamId = abi.decode(response, (uint256));
    }

    /// @dev Creates a default stream with range given the `nonce`.
    function createWithRangeWithNonce(uint48 nonce) internal returns (uint256 streamId) {
        Permit2Params memory _permit2Params = Permit2Params({
            permit2: permit2,
            expiration: DefaultParams.PERMIT2_EXPIRATION,
            sigDeadline: DefaultParams.PERMIT2_SIG_DEADLINE,
            signature: getPermit2Signature(
                DefaultParams.permitDetailsWithNonce(address(asset), nonce), privateKeys.sender, address(proxy)
                )
        });

        bytes memory data = abi.encodeCall(
            target.createWithRange,
            (linear, DefaultParams.createWithRange(users, address(proxy), asset), _permit2Params)
        );
        bytes memory response = proxy.execute(address(target), data);
        streamId = abi.decode(response, (uint256));
    }
}
