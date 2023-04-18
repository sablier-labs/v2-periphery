// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Errors } from "src/libraries/Errors.sol";
import { Batch } from "src/types/DataTypes.sol";

import { Base_Test } from "../../Base.t.sol";
import { Defaults } from "../../helpers/Defaults.t.sol";

contract BatchCreateWithMilestones_Unit_Test is Base_Test {
    function test_RevertWhen_BatchSizeZero() external {
        Batch.CreateWithMilestones[] memory batch = new Batch.CreateWithMilestones[](0);
        bytes memory data = abi.encodeCall(
            target.batchCreateWithMilestones, (dynamic, dai, batch, permit2Params(defaults.TRANSFER_AMOUNT()))
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
        expectCallToTransferFrom({ from: users.sender.addr, to: address(proxy), amount: defaults.TRANSFER_AMOUNT() });
        expectMultipleCallsToCreateWithMilestones({ params: defaults.createWithMilestones() });
        expectMultipleCallsToTransferFrom({
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
