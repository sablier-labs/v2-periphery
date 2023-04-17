// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Errors } from "src/libraries/Errors.sol";
import { Batch } from "src/types/DataTypes.sol";

import { Base_Test } from "../../Base.t.sol";
import { Defaults } from "../../helpers/Defaults.t.sol";

contract BatchCreateWithDurations_Unit_Test is Base_Test {
    function test_RevertWhen_BatchSizeZero() external {
        Batch.CreateWithDurations[] memory params = new Batch.CreateWithDurations[](0);
        vm.expectRevert(Errors.SablierV2ProxyTarget_BatchSizeZero.selector);
        bytes memory data = abi.encodeCall(
            target.batchCreateWithDurations, (linear, dai, params, permit2Params(Defaults.TRANSFER_AMOUNT))
        );
        proxy.execute(address(target), data);
    }

    modifier whenBatchSizeNotZero() {
        _;
    }

    function test_BatchCreateWithDurations() external whenBatchSizeNotZero {
        // Asset flow: proxy owner → proxy → Sablier
        // Expect transfers from the proxy owner to the proxy, and then from the proxy to the Sablier contract.
        expectCallToTransferFrom({ from: users.sender.addr, to: address(proxy), amount: Defaults.TRANSFER_AMOUNT });
        expectMultipleCallsToCreateWithDurations({ params: Defaults.createWithDurations(users, proxy, dai) });
        expectMultipleCallsToTransferFrom({
            from: address(proxy),
            to: address(linear),
            amount: Defaults.PER_STREAM_AMOUNT
        });

        // Assert that the batch of streams has been created successfully.
        uint256[] memory actualStreamIds = batchCreateWithDurations();
        uint256[] memory expectedStreamIds = Defaults.streamIds();
        assertEq(actualStreamIds, expectedStreamIds, "stream ids do not match");
    }
}
