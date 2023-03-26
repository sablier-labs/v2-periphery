// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Unit_Test } from "../Unit.t.sol";
import { DefaultParams } from "../../helpers/DefaultParams.t.sol";

contract CancelAndCreateWithMilestones_Test is Unit_Test {
    function setUp() public virtual override {
        Unit_Test.setUp();

        changePrank(users.sender);
    }

    function test_CancelAndCreateWithMilestones() external {
        uint256 streamId = createWithMilestonesDefault();

        expectTransferCall(users.sender, DefaultParams.TOTAL_AMOUNT);
        expectTransferFromCall(users.sender, address(proxy), DefaultParams.TOTAL_AMOUNT);

        uint256 expectedNewStreamId = dynamic.nextStreamId();
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithMilestones,
            (
                dynamic,
                dynamic,
                streamId,
                DefaultParams.createWithMilestones(users, address(proxy), asset),
                permit2ParamsWithNonce(1)
            )
        );
        bytes memory response = proxy.execute(address(target), data);
        uint256 actualNewStreamId = abi.decode(response, (uint256));

        assertEq(actualNewStreamId, expectedNewStreamId);
    }

    function test_CancelAndCreateWithMilestones_DifferentStreams() external {
        uint256 streamId = createWithRangeDefault();

        expectTransferCall(users.sender, DefaultParams.TOTAL_AMOUNT);
        expectTransferFromCall(users.sender, address(proxy), DefaultParams.TOTAL_AMOUNT);

        uint256 expectedNewStreamId = dynamic.nextStreamId();
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithMilestones,
            (
                linear,
                dynamic,
                streamId,
                DefaultParams.createWithMilestones(users, address(proxy), asset),
                permit2ParamsWithNonce(1)
            )
        );
        bytes memory response = proxy.execute(address(target), data);
        uint256 actualNewStreamId = abi.decode(response, (uint256));

        assertEq(actualNewStreamId, expectedNewStreamId);
    }
}
