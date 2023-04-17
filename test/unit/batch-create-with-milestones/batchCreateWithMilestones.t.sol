// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Errors } from "src/libraries/Errors.sol";
import { Batch } from "src/types/DataTypes.sol";

import { Unit_Test } from "../Unit.t.sol";
import { DefaultParams } from "../../helpers/DefaultParams.t.sol";

contract BatchCreateWithMilestones_Test is Unit_Test {
    function setUp() public virtual override {
        Unit_Test.setUp();

        changePrank(users.sender);
    }

    function test_RevertWhen_BatchEmpty() external {
        Batch.CreateWithMilestones[] memory params;
        bytes memory data = abi.encodeCall(
            target.batchCreateWithMilestones, (dynamic, asset, params, permit2Params(DefaultParams.TOTAL_AMOUNT))
        );
        vm.expectRevert(Errors.SablierV2ProxyTarget_BatchEmpty.selector);
        proxy.execute(address(target), data);
    }

    modifier whenBatchNotEmpty() {
        _;
    }

    function test_BatchCreateWithMilestones() external whenBatchNotEmpty {
        // Asset flow: sender -> proxy -> dynamic
        expectTransferFromCall(users.sender, address(proxy), DefaultParams.TOTAL_AMOUNT);
        expectMultipleCreateWithMilestonesCalls(DefaultParams.createWithMilestones(users, address(proxy), asset));
        expectMultipleTransferCalls(address(proxy), address(dynamic), DefaultParams.AMOUNT);

        uint256[] memory streamIds = batchCreateWithMilestonesDefault();
        assertEq(streamIds, DefaultParams.streamIds());
    }
}
