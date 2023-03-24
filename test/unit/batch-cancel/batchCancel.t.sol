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

    function test_BatchCancel() external {
        uint256 dynamicStreamId = createWithMilestonesDefaultWithNonce(0);
        uint256 linearStreamId = createWithRangeDefaultWithNonce(1);

        Batch.Cancel[] memory params = new Batch.Cancel[](2);
        params[0] = Batch.Cancel(dynamic, dynamicStreamId);
        params[1] = Batch.Cancel(linear, linearStreamId);

        Lockup.Status beforeDynamicStatus = dynamic.getStatus(dynamicStreamId);
        Lockup.Status beforeLinearStatus = linear.getStatus(linearStreamId);

        assertEq(beforeDynamicStatus, DefaultParams.statusBeforeCancel());
        assertEq(beforeLinearStatus, DefaultParams.statusBeforeCancel());

        // Asset flow: dynamic -> proxy -> sender
        expectTransferCall(address(proxy), DefaultParams.TOTAL_AMOUNT);
        expectTransferCall(users.sender, DefaultParams.TOTAL_AMOUNT);
        // Asset flow: linear -> proxy -> sender
        expectTransferCall(address(proxy), DefaultParams.TOTAL_AMOUNT);
        expectTransferCall(users.sender, DefaultParams.TOTAL_AMOUNT);

        bytes memory data = abi.encodeCall(target.batchCancel, (params));
        proxy.execute(address(target), data);

        Lockup.Status afterDynamicStatus = dynamic.getStatus(dynamicStreamId);
        Lockup.Status afterLinearStatus = linear.getStatus(linearStreamId);

        assertEq(afterDynamicStatus, DefaultParams.statusAfterCancel());
        assertEq(afterLinearStatus, DefaultParams.statusAfterCancel());
    }
}
