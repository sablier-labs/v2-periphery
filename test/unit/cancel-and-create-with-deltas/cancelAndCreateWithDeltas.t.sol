// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Unit_Test } from "../Unit.t.sol";
import { DefaultParams } from "../../helpers/DefaultParams.t.sol";

contract CancelAndCreateWithDeltas_Test is Unit_Test {
    function setUp() public virtual override {
        Unit_Test.setUp();

        changePrank(users.sender);
    }

    function test_CancelAndCreateWithDeltas() external {
        uint256 streamId = createWithDeltasDefault();

        expectTransferCall(users.sender, DefaultParams.TOTAL_AMOUNT);
        expectTransferFromCall(users.sender, address(proxy), DefaultParams.TOTAL_AMOUNT);

        uint256 expectedNewStreamId = dynamic.nextStreamId();
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithDeltas,
            (
                dynamic,
                dynamic,
                streamId,
                DefaultParams.createWithDeltas(users, address(proxy), asset),
                permit2ParamsWithNonce(1)
            )
        );
        bytes memory response = proxy.execute(address(target), data);
        uint256 actualNewStreamId = abi.decode(response, (uint256));

        assertEq(actualNewStreamId, expectedNewStreamId);
    }

    function test_CancelAndCreateWithDeltas_DifferentStreams() external {
        uint256 streamId = createWithRangeDefault();

        expectTransferCall(users.sender, DefaultParams.TOTAL_AMOUNT);
        expectTransferFromCall(users.sender, address(proxy), DefaultParams.TOTAL_AMOUNT);

        uint256 expectedNewStreamId = dynamic.nextStreamId();
        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithDeltas,
            (
                linear,
                dynamic,
                streamId,
                DefaultParams.createWithDeltas(users, address(proxy), asset),
                permit2ParamsWithNonce(1)
            )
        );
        bytes memory response = proxy.execute(address(target), data);
        uint256 actualNewStreamId = abi.decode(response, (uint256));

        assertEq(actualNewStreamId, expectedNewStreamId);
    }
}
