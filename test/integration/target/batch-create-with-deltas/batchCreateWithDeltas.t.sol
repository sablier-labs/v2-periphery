// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Errors } from "src/libraries/Errors.sol";
import { Batch, Permit2Params } from "src/types/DataTypes.sol";

import { Integration_Test } from "../../Integration.t.sol";

contract BatchCreateWithDeltas_Integration_Test is Integration_Test {
    function test_RevertWhen_NotDelegateCalled() external {
        Batch.CreateWithDeltas[] memory batch;
        Permit2Params memory permit2Params;
        vm.expectRevert(Errors.CallNotDelegateCall.selector);
        target.batchCreateWithDeltas(dynamic, dai, batch, permit2Params);
    }

    modifier whenDelegateCalled() {
        _;
    }

    function test_RevertWhen_BatchSizeZero() external whenDelegateCalled {
        Batch.CreateWithDeltas[] memory batch = new Batch.CreateWithDeltas[](0);
        Permit2Params memory permit2Params;
        bytes memory data = abi.encodeCall(target.batchCreateWithDeltas, (dynamic, dai, batch, permit2Params));
        vm.expectRevert(Errors.SablierV2ProxyTarget_BatchSizeZero.selector);
        proxy.execute(address(target), data);
    }

    modifier whenBatchSizeNotZero() {
        _;
    }

    function test_BatchCreateWithDeltas() external whenBatchSizeNotZero whenDelegateCalled {
        // Asset flow: proxy owner → proxy → Sablier
        // Expect transfers from the proxy owner to the proxy, and then from the proxy to the Sablier contract.
        expectCallToTransferFrom({ from: users.alice.addr, to: address(proxy), amount: defaults.TRANSFER_AMOUNT() });
        expectMultipleCallsToCreateWithDeltas({ count: defaults.BATCH_SIZE(), params: defaults.createWithDeltas() });
        expectMultipleCallsToTransferFrom({
            count: defaults.BATCH_SIZE(),
            from: address(proxy),
            to: address(dynamic),
            amount: defaults.PER_STREAM_AMOUNT()
        });

        // Assert that the batch of streams has been created successfully.
        uint256[] memory actualStreamIds = batchCreateWithDeltas();
        uint256[] memory expectedStreamIds = defaults.incrementalStreamIds();
        assertEq(actualStreamIds, expectedStreamIds, "stream ids do not match");
    }
}