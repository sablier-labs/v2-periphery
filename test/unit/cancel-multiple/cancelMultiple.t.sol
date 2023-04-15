// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { Lockup } from "@sablier/v2-core/types/DataTypes.sol";

import { Batch } from "src/types/DataTypes.sol";

import { Unit_Test } from "../Unit.t.sol";
import { DefaultParams } from "../../helpers/DefaultParams.t.sol";

contract BatchCreateWithDeltas_Test is Unit_Test {
    function setUp() public virtual override {
        Unit_Test.setUp();

        changePrank(users.sender);
    }

    function test_CancelMultiple() external {
        uint256[] memory streamIds = batchCreateWithRangeDefault();

        Lockup.Status[] memory beforeStatuses = new Lockup.Status[](DefaultParams.BATCH_COUNT);

        for (uint256 i = 0; i < DefaultParams.BATCH_COUNT; ++i) {
            beforeStatuses[i] = linear.getStatus(streamIds[i]);
        }

        assertEq(beforeStatuses, DefaultParams.statusesBeforeCancelMultiple());

        vm.warp(DefaultParams.TIME_WARP);

        // Asset flow: linear -> proxy -> sender
        expectMultipleTransferCalls(address(proxy), DefaultParams.REFUND_AMOUNT);
        expectTransferCall(users.sender, DefaultParams.REFUND_AMOUNT * DefaultParams.BATCH_COUNT);

        bytes memory data = abi.encodeCall(target.cancelMultiple, (linear, DefaultParams.assets(asset), streamIds));
        proxy.execute(address(target), data);

        Lockup.Status[] memory afterStatuses = new Lockup.Status[](DefaultParams.BATCH_COUNT);

        for (uint256 i = 0; i < DefaultParams.BATCH_COUNT; ++i) {
            afterStatuses[i] = linear.getStatus(streamIds[i]);
        }

        assertEq(afterStatuses, DefaultParams.statusesAfterCancelMultiple());
    }
}
