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

        bytes memory data = abi.encodeCall(
            target.cancelAndCreateWithRange,
            (
                linear,
                linear,
                streamId,
                DefaultParams.createWithRange(users, address(proxy), asset),
                permit2ParamsWithNonce(1)
            )
        );
        bytes memory response = proxy.execute(address(target), data);
        uint256 actualNewStreamId = abi.decode(response, (uint256));
        uint256 expectedNewStreamId = streamId + 1;

        assertEq(actualNewStreamId, expectedNewStreamId);
    }
}
