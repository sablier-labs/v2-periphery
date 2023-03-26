// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Lockup } from "@sablier/v2-core/types/DataTypes.sol";

import { Batch } from "src/types/DataTypes.sol";

import { Unit_Test } from "../Unit.t.sol";
import { DefaultParams } from "../../helpers/DefaultParams.t.sol";

contract BatchCreateWithDeltas_Test is Unit_Test {
    function setUp() public virtual override {
        Unit_Test.setUp();

        changePrank(users.sender);
    }

    function test_BatchCancelMultiple() external {
        uint256[] memory dynamicStreamIds = batchCreateWithMilestonesDefaultWithNonce(0);
        uint256[] memory linearStreamIds = batchCreateWithRangeDefaultWithNonce(1);

        Batch.CancelMultiple[] memory params = new Batch.CancelMultiple[](2);
        params[0] = Batch.CancelMultiple(dynamic, dynamicStreamIds);
        params[1] = Batch.CancelMultiple(linear, linearStreamIds);

        Lockup.Status[] memory beforeDynamicStatuses = new Lockup.Status[](DefaultParams.BATCH_CREATE_PARAMS_COUNT);
        Lockup.Status[] memory beforeLinearStatuses = new Lockup.Status[](DefaultParams.BATCH_CREATE_PARAMS_COUNT);

        for (uint256 i = 0; i < DefaultParams.BATCH_CREATE_PARAMS_COUNT; ++i) {
            beforeDynamicStatuses[i] = dynamic.getStatus(dynamicStreamIds[i]);
            beforeLinearStatuses[i] = linear.getStatus(linearStreamIds[i]);
        }

        assertEq(beforeDynamicStatuses, DefaultParams.statusesBeforeCancelMultiple());
        assertEq(beforeLinearStatuses, DefaultParams.statusesBeforeCancelMultiple());

        // Asset flow: dynamic -> proxy -> sender
        expectMultipleTransferCalls(address(proxy), DefaultParams.AMOUNT);
        // Asset flow: linear -> proxy -> sender
        expectMultipleTransferCalls(address(proxy), DefaultParams.AMOUNT);
        expectTransferCall(users.sender, 2 * DefaultParams.TOTAL_AMOUNT);

        bytes memory data = abi.encodeCall(target.batchCancelMultiple, (params, DefaultParams.assets(asset)));
        proxy.execute(address(target), data);

        Lockup.Status[] memory afterDynamicStatuses = new Lockup.Status[](DefaultParams.BATCH_CREATE_PARAMS_COUNT);
        Lockup.Status[] memory afterLinearStatuses = new Lockup.Status[](DefaultParams.BATCH_CREATE_PARAMS_COUNT);

        for (uint256 i = 0; i < DefaultParams.BATCH_CREATE_PARAMS_COUNT; ++i) {
            afterDynamicStatuses[i] = dynamic.getStatus(dynamicStreamIds[i]);
            afterLinearStatuses[i] = linear.getStatus(linearStreamIds[i]);
        }

        assertEq(afterDynamicStatuses, DefaultParams.statusesAfterCancelMultiple());
        assertEq(afterLinearStatuses, DefaultParams.statusesAfterCancelMultiple());
    }
}
