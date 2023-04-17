// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Unit_Test } from "../Unit.t.sol";
import { DefaultParams } from "../../helpers/DefaultParams.t.sol";

contract CancelAndCreateWithRange_Test is Unit_Test {
    function setUp() public virtual override {
        Unit_Test.setUp();

        changePrank({ msgSender: users.sender.addr });
    }

    function expectCancelAndTransferCalls(address cancelLockup, address createLockup, uint256 streamId) internal {
        expectCancelCall(cancelLockup, streamId);
        expectTransferCall(address(proxy), DefaultParams.PER_STREAM_TOTAL_AMOUNT);
        expectTransferCall(users.sender.addr, DefaultParams.PER_STREAM_TOTAL_AMOUNT);
        expectTransferFromCall(users.sender.addr, address(proxy), DefaultParams.PER_STREAM_TOTAL_AMOUNT);
        expectTransferFromCall(address(proxy), createLockup, DefaultParams.PER_STREAM_TOTAL_AMOUNT);
    }

    function test_CancelAndCreateWithDeltas() external {
        uint256 streamId = createWithDeltasDefault();

        expectCancelAndTransferCalls(address(dynamic), address(dynamic), streamId);
        expectCreateWithDeltasCall(DefaultParams.createWithDeltas(users, address(proxy), asset));

        uint256 expectedNewStreamId = dynamic.nextStreamId();
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithDeltas,
            (
                dynamic,
                dynamic,
                streamId,
                DefaultParams.createWithDeltas(users, address(proxy), asset),
                permit2ParamsWithNonce(DefaultParams.PER_STREAM_TOTAL_AMOUNT, 1)
            )
        );
        bytes memory response = proxy.execute(address(target), data);
        uint256 actualNewStreamId = abi.decode(response, (uint256));

        assertEq(actualNewStreamId, expectedNewStreamId);
    }

    function test_CancelAndCreateWithDeltas_DifferentStreams() external {
        uint256 streamId = createWithRangeDefault();

        expectCancelAndTransferCalls(address(linear), address(dynamic), streamId);
        expectCreateWithDeltasCall(DefaultParams.createWithDeltas(users, address(proxy), asset));

        uint256 expectedNewStreamId = dynamic.nextStreamId();
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithDeltas,
            (
                linear,
                dynamic,
                streamId,
                DefaultParams.createWithDeltas(users, address(proxy), asset),
                permit2ParamsWithNonce(DefaultParams.PER_STREAM_TOTAL_AMOUNT, 1)
            )
        );
        bytes memory response = proxy.execute(address(target), data);
        uint256 actualNewStreamId = abi.decode(response, (uint256));

        assertEq(actualNewStreamId, expectedNewStreamId);
    }

    function test_CancelAndCreateWithDurations() external {
        uint256 streamId = createWithDurationsDefault();

        expectCancelAndTransferCalls(address(linear), address(linear), streamId);
        expectCreateWithDurationsCall(DefaultParams.createWithDurations(users, address(proxy), asset));

        uint256 expectedNewStreamId = linear.nextStreamId();
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithDurations,
            (
                linear,
                linear,
                streamId,
                DefaultParams.createWithDurations(users, address(proxy), asset),
                permit2ParamsWithNonce(DefaultParams.PER_STREAM_TOTAL_AMOUNT, 1)
            )
        );
        bytes memory response = proxy.execute(address(target), data);
        uint256 actualNewStreamId = abi.decode(response, (uint256));

        assertEq(actualNewStreamId, expectedNewStreamId);
    }

    function test_CancelAndCreateWithDurations_DifferentStreams() external {
        uint256 streamId = createWithMilestonesDefault();

        expectCancelAndTransferCalls(address(dynamic), address(linear), streamId);
        expectCreateWithDurationsCall(DefaultParams.createWithDurations(users, address(proxy), asset));

        uint256 expectedNewStreamId = linear.nextStreamId();
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithDurations,
            (
                dynamic,
                linear,
                streamId,
                DefaultParams.createWithDurations(users, address(proxy), asset),
                permit2ParamsWithNonce(DefaultParams.PER_STREAM_TOTAL_AMOUNT, 1)
            )
        );
        bytes memory response = proxy.execute(address(target), data);
        uint256 actualNewStreamId = abi.decode(response, (uint256));

        assertEq(actualNewStreamId, expectedNewStreamId);
    }

    function test_CancelAndCreateWithMilestones() external {
        uint256 streamId = createWithMilestonesDefault();

        expectCancelAndTransferCalls(address(dynamic), address(dynamic), streamId);
        expectCreateWithMilestonesCall(DefaultParams.createWithMilestones(users, address(proxy), asset));

        uint256 expectedNewStreamId = dynamic.nextStreamId();
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithMilestones,
            (
                dynamic,
                dynamic,
                streamId,
                DefaultParams.createWithMilestones(users, address(proxy), asset),
                permit2ParamsWithNonce(DefaultParams.PER_STREAM_TOTAL_AMOUNT, 1)
            )
        );
        bytes memory response = proxy.execute(address(target), data);
        uint256 actualNewStreamId = abi.decode(response, (uint256));

        assertEq(actualNewStreamId, expectedNewStreamId);
    }

    function test_CancelAndCreateWithMilestones_DifferentStreams() external {
        uint256 streamId = createWithRangeDefault();

        expectCancelAndTransferCalls(address(linear), address(dynamic), streamId);
        expectCreateWithMilestonesCall(DefaultParams.createWithMilestones(users, address(proxy), asset));

        uint256 expectedNewStreamId = dynamic.nextStreamId();
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithMilestones,
            (
                linear,
                dynamic,
                streamId,
                DefaultParams.createWithMilestones(users, address(proxy), asset),
                permit2ParamsWithNonce(DefaultParams.PER_STREAM_TOTAL_AMOUNT, 1)
            )
        );
        bytes memory response = proxy.execute(address(target), data);
        uint256 actualNewStreamId = abi.decode(response, (uint256));

        assertEq(actualNewStreamId, expectedNewStreamId);
    }

    function test_CancelAndCreateWithRange() external {
        uint256 streamId = createWithRangeDefault();

        expectCancelAndTransferCalls(address(linear), address(linear), streamId);
        expectCreateWithRangeCall(DefaultParams.createWithRange(users, address(proxy), asset));

        uint256 expectedNewStreamId = linear.nextStreamId();
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithRange,
            (
                linear,
                linear,
                streamId,
                DefaultParams.createWithRange(users, address(proxy), asset),
                permit2ParamsWithNonce(DefaultParams.PER_STREAM_TOTAL_AMOUNT, 1)
            )
        );
        bytes memory response = proxy.execute(address(target), data);
        uint256 actualNewStreamId = abi.decode(response, (uint256));

        assertEq(actualNewStreamId, expectedNewStreamId);
    }

    function test_CancelAndCreateWithRange_DifferentStreams() external {
        uint256 streamId = createWithMilestonesDefault();

        expectCancelAndTransferCalls(address(dynamic), address(linear), streamId);
        expectCreateWithRangeCall(DefaultParams.createWithRange(users, address(proxy), asset));

        uint256 expectedNewStreamId = linear.nextStreamId();
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithRange,
            (
                dynamic,
                linear,
                streamId,
                DefaultParams.createWithRange(users, address(proxy), asset),
                permit2ParamsWithNonce(DefaultParams.PER_STREAM_TOTAL_AMOUNT, 1)
            )
        );
        bytes memory response = proxy.execute(address(target), data);
        uint256 actualNewStreamId = abi.decode(response, (uint256));

        assertEq(actualNewStreamId, expectedNewStreamId);
    }
}
