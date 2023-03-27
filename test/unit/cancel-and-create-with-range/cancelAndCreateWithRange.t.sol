// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Unit_Test } from "../Unit.t.sol";
import { DefaultParams } from "../../helpers/DefaultParams.t.sol";

contract CancelAndCreateWithRange_Test is Unit_Test {
    function setUp() public virtual override {
        Unit_Test.setUp();

        changePrank(users.sender);
    }

    function test_CancelAndCreateWithRange() external {
        uint256 streamId = createWithRangeDefault();

        expectCancelCall(address(linear), streamId);
        expectTransferCall(address(proxy), DefaultParams.AMOUNT);
        expectTransferCall(users.sender, DefaultParams.AMOUNT);
        expectCreateWithRangeCall(DefaultParams.createWithRange(users, address(proxy), asset));
        expectTransferFromCall(users.sender, address(proxy), DefaultParams.AMOUNT);
        expectTransferFromCall(address(proxy), address(linear), DefaultParams.AMOUNT);

        uint256 expectedNewStreamId = linear.nextStreamId();
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithRange,
            (
                linear,
                linear,
                streamId,
                DefaultParams.createWithRange(users, address(proxy), asset),
                permit2ParamsWithNonce(DefaultParams.AMOUNT, 1)
            )
        );
        bytes memory response = proxy.execute(address(target), data);
        uint256 actualNewStreamId = abi.decode(response, (uint256));

        assertEq(actualNewStreamId, expectedNewStreamId);
    }

    function test_CancelAndCreateWithRange_DifferentStreams() external {
        uint256 streamId = createWithMilestonesDefault();

        expectCancelCall(address(dynamic), streamId);
        expectTransferCall(address(proxy), DefaultParams.AMOUNT);
        expectTransferCall(users.sender, DefaultParams.AMOUNT);
        expectCreateWithRangeCall(DefaultParams.createWithRange(users, address(proxy), asset));
        expectTransferFromCall(users.sender, address(proxy), DefaultParams.AMOUNT);
        expectTransferFromCall(address(proxy), address(linear), DefaultParams.AMOUNT);

        uint256 expectedNewStreamId = linear.nextStreamId();
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithRange,
            (
                dynamic,
                linear,
                streamId,
                DefaultParams.createWithRange(users, address(proxy), asset),
                permit2ParamsWithNonce(DefaultParams.AMOUNT, 1)
            )
        );
        bytes memory response = proxy.execute(address(target), data);
        uint256 actualNewStreamId = abi.decode(response, (uint256));

        assertEq(actualNewStreamId, expectedNewStreamId);
    }
}
