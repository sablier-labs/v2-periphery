// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Fuzzers } from "@sablier/v2-core-test/utils/Fuzzers.sol";

import { IWrappedNativeAsset } from "src/interfaces/IWrappedNativeAsset.sol";
import { LockupDynamic } from "src/types/DataTypes.sol";

import { Fork_Test } from "../Fork.t.sol";

contract WrapAndCreate_Fork_Test is Fork_Test, Fuzzers {
    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Runs against the actual wrapped native asset only.
    constructor() Fork_Test(weth) { }

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function test_ForkFuzz_WrapAndCreate(uint256 etherAmount) external {
        // Bound the ether amount so that Alice has enough ether to create two streams.
        etherAmount = _bound(etherAmount, 1, users.alice.addr.balance / 2);

        /*//////////////////////////////////////////////////////////////////////////
                               CREATE WITH MILESTONES
        //////////////////////////////////////////////////////////////////////////*/

        // Expect the correct calls to be made.
        vm.expectCall(address(weth), abi.encodeCall(IWrappedNativeAsset.deposit, ()));
        expectCallToTransferFrom({
            asset: address(weth),
            from: address(proxy),
            to: address(dynamic),
            amount: etherAmount
        });

        LockupDynamic.CreateWithMilestones memory params = defaults.createWithMilestones(weth);
        params.segments[0].amount = uint128(etherAmount);
        params.segments[1].amount = 0;

        // ABI encode the parameters and call the function via the proxy.
        bytes memory data = abi.encodeCall(target.wrapAndCreateWithMilestones, (dynamic, params));
        bytes memory response = proxy.execute{ value: etherAmount }(address(target), data);

        // Assert that the stream has been created successfully.
        uint256 actualStreamId = abi.decode(response, (uint256));
        uint256 expectedStreamId = dynamic.nextStreamId() - 1;
        assertEq(actualStreamId, expectedStreamId, "stream id mismatch");

        /*//////////////////////////////////////////////////////////////////////////
                                 CREATE WITH RANGE
        //////////////////////////////////////////////////////////////////////////*/

        // Expect the correct calls to be made.
        vm.expectCall(address(weth), abi.encodeCall(IWrappedNativeAsset.deposit, ()));
        expectCallToTransferFrom({ asset: address(weth), from: address(proxy), to: address(linear), amount: etherAmount });

        // ABI encode the parameters and call the function via the proxy.
        data = abi.encodeCall(target.wrapAndCreateWithRange, (linear, defaults.createWithRange(weth)));
        response = proxy.execute{ value: etherAmount }(address(target), data);

        // Assert that the stream has been created successfully.
        actualStreamId = abi.decode(response, (uint256));
        expectedStreamId = linear.nextStreamId() - 1;
        assertEq(actualStreamId, expectedStreamId, "stream id mismatch");
    }
}
