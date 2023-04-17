// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Errors } from "src/libraries/Errors.sol";
import { Batch } from "src/types/DataTypes.sol";

import { Unit_Test } from "../Unit.t.sol";
import { DefaultParams } from "../../helpers/DefaultParams.t.sol";

contract BatchCreateWithDurations_Test is Unit_Test {
    function setUp() public virtual override {
        Unit_Test.setUp();

        changePrank(users.sender);
    }

    function test_RevertWhen_BatchEmpty() external {
        Batch.CreateWithDurations[] memory params;
        bytes memory data = abi.encodeCall(
            target.batchCreateWithDurations, (linear, asset, params, permit2Params(DefaultParams.TOTAL_AMOUNT))
        );
        vm.expectRevert(Errors.SablierV2ProxyTarget_BatchEmpty.selector);
        proxy.execute(address(target), data);
    }

    modifier whenBatchNotEmpty() {
        _;
    }

    function test_BatchCreateWithDurations() external whenBatchNotEmpty {
        // Asset flow: sender -> proxy -> linear
        expectTransferFromCall(users.sender, address(proxy), DefaultParams.TOTAL_AMOUNT);
        expectMultipleCreateWithDurationsCalls(DefaultParams.createWithDurations(users, address(proxy), asset));
        expectMultipleTransferCalls(address(proxy), address(linear), DefaultParams.AMOUNT);

        uint256[] memory streamIds = batchCreateWithDurationsDefault();
        assertEq(streamIds, DefaultParams.streamIds());
    }
}
