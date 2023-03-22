// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Errors } from "src/libraries/Errors.sol";
import { Batch } from "src/types/DataTypes.sol";

import { Unit_Test } from "../Unit.t.sol";

contract BatchCreateWithDeltas_Test is Unit_Test {
    function setUp() public virtual override {
        Unit_Test.setUp();

        changePrank(users.sender);
    }

    /// @dev it should revert.
    function test_RevertWhen_TotalAmountZero() external {
        uint128 totalAmountZero = 0;
        bytes memory data = abi.encodeCall(
            target.batchCreateWithDeltas, (dynamic, asset, totalAmountZero, defaultDeltasParams(), defaultPermit2Params)
        );
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2ProxyTarget_TotalAmountZero.selector));
        proxy.execute(address(target), data);
    }

    modifier whenTotalAmountNotZero() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_ParamsCountZero() external whenTotalAmountNotZero {
        Batch.CreateWithDeltas[] memory params;
        bytes memory data = abi.encodeCall(
            target.batchCreateWithDeltas, (dynamic, asset, DEFAULT_TOTAL_AMOUNT, params, defaultPermit2Params)
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierV2ProxyTarget_TotalAmountNotEqualToAmountsSum.selector, DEFAULT_TOTAL_AMOUNT, 0
            )
        );
        proxy.execute(address(target), data);
    }

    modifier whenParamsCountNotZero() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_TotalAmountNotEqualToAmountsSum() external whenTotalAmountNotZero whenParamsCountNotZero {
        uint128 totalAmount = DEFAULT_TOTAL_AMOUNT - 1;
        bytes memory data = abi.encodeCall(
            target.batchCreateWithDeltas, (dynamic, asset, totalAmount, defaultDeltasParams(), defaultPermit2Params)
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierV2ProxyTarget_TotalAmountNotEqualToAmountsSum.selector, totalAmount, DEFAULT_TOTAL_AMOUNT
            )
        );
        proxy.execute(address(target), data);
    }

    modifier whenTotalAmountEqualToAmountsSum() {
        _;
    }

    /// @dev it should create multiple streams.
    function test_BatchCreateWithDeltas()
        external
        whenTotalAmountNotZero
        whenParamsCountNotZero
        whenTotalAmountEqualToAmountsSum
    {
        expectTransferFromCall(users.sender, address(proxy), DEFAULT_TOTAL_AMOUNT);
        expectTransferFromCallMutiple(address(proxy), address(dynamic), DEFAULT_AMOUNT);

        uint256[] memory streamIds = batchCreateWithDeltasDefault();

        assertEq(streamIds, DEFAULT_STREAM_IDS);
    }
}
