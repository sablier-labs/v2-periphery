// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Errors } from "src/libraries/Errors.sol";
import { Batch } from "src/types/DataTypes.sol";

import { Unit_Test } from "../Unit.t.sol";
import { DefaultParams } from "../../helpers/DefaultParams.t.sol";

contract BatchCreateWithDeltas_Test is Unit_Test {
    function setUp() public virtual override {
        Unit_Test.setUp();

        changePrank(users.sender);
    }

    function test_RevertWhen_BatchEmpty() external {
        Batch.CreateWithDeltas[] memory params;
        bytes memory data = abi.encodeCall(
            target.batchCreateWithDeltas, (dynamic, asset, params, permit2Params(DefaultParams.TRANSFER_AMOUNT))
        );
        vm.expectRevert(Errors.SablierV2ProxyTarget_BatchEmpty.selector);
        proxy.execute(address(target), data);
    }

    modifier whenBatchNotEmpty() {
        _;
    }

    function test_BatchCreateWithDeltas() external whenBatchNotEmpty {
        // Asset flow: sender -> proxy -> dynamic
        expectTransferFromCall(users.sender, address(proxy), DefaultParams.TRANSFER_AMOUNT);
        expectMultipleCreateWithDeltasCalls(DefaultParams.createWithDeltas(users, address(proxy), asset));
        expectMultipleTransferCalls(address(proxy), address(dynamic), DefaultParams.PER_STREAM_TOTAL_AMOUNT);

        uint256[] memory streamIds = batchCreateWithDeltasDefault();
        assertEq(streamIds, DefaultParams.streamIds());
    }
}
