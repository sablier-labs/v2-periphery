// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Errors } from "src/libraries/Errors.sol";
import { Batch } from "src/types/DataTypes.sol";

import { Defaults } from "../../../utils/Defaults.sol";
import { Unit_Test } from "../../Unit.t.sol";

contract BatchCreateWithMilestones_Unit_Test is Unit_Test {
    function test_RevertWhen_BatchSizeZero() external {
        Batch.CreateWithMilestones[] memory batch = new Batch.CreateWithMilestones[](0);
        bytes memory data = abi.encodeCall(
            target.batchCreateWithMilestones, (dynamic, dai, batch, permit2, permit2Params(defaults.TRANSFER_AMOUNT()))
        );
        vm.expectRevert(Errors.SablierV2ProxyTarget_BatchSizeZero.selector);
        proxy.execute(address(target), data);
    }

    modifier whenBatchSizeNotZero() {
        _;
    }

    function test_BatchCreateWithMilestones() external whenBatchSizeNotZero {
        // Asset flow: proxy owner → proxy → Sablier
        // Expect transfers from the proxy owner to the proxy, and then from the proxy to the Sablier contract.
        expectCallToTransferFrom({ from: users.alice.addr, to: address(proxy), amount: defaults.TRANSFER_AMOUNT() });
        expectMultipleCallsToCreateWithMilestones({
            count: defaults.BATCH_SIZE(),
            params: defaults.createWithMilestones()
        });
        expectMultipleCallsToTransferFrom({
            count: defaults.BATCH_SIZE(),
            from: address(proxy),
            to: address(dynamic),
            amount: defaults.PER_STREAM_AMOUNT()
        });

        // Assert that the batch of streams has been created successfully.
        uint256[] memory actualStreamIds = batchCreateWithMilestones();
        uint256[] memory expectedStreamIds = defaults.incrementalStreamIds();
        assertEq(actualStreamIds, expectedStreamIds, "stream ids do not match");
    }
}
