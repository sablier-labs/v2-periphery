// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <0.9.0;

import { Errors } from "src/libraries/Errors.sol";
import { CreateLinear } from "src/types/DataTypes.sol";

import { Unit_Test } from "../Unit.t.sol";

contract CreateWithRangeMultiple_Test is Unit_Test {
    function setUp() public virtual override {
        Unit_Test.setUp();

        changePrank(users.sender);
    }

    /// @dev it should revert.
    function test_RevertWhen_TotalAmountZero() external {
        uint128 totalAmountZero = 0;
        // Expect a {BatchStream_TotalAmountZero} error.
        vm.expectRevert(abi.encodeWithSelector(Errors.BatchStream_TotalAmountZero.selector));
        batch.createWithRangeMultiple(linear, defaultRangeParams(), asset, totalAmountZero);
    }

    modifier totalAmountNotZero() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_ParamsCountZero() external totalAmountNotZero {
        CreateLinear.RangeParams[] memory params;
        // Expect a {BatchStream_ParamsCountZero} error.
        vm.expectRevert(abi.encodeWithSelector(Errors.BatchStream_ParamsCountZero.selector));
        batch.createWithRangeMultiple(linear, params, asset, DEFAULT_TOTAL_AMOUNT);
    }

    modifier paramsCountNotZero() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_TotalAmountNotEqualToAmountsSum() external totalAmountNotZero paramsCountNotZero {
        uint128 totalAmount = DEFAULT_TOTAL_AMOUNT - 1;
        // Expect a {BatchStream_TotalAmountNotEqualToAmountsSum} error.
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.BatchStream_TotalAmountNotEqualToAmountsSum.selector,
                totalAmount,
                DEFAULT_TOTAL_AMOUNT
            )
        );
        batch.createWithRangeMultiple(linear, defaultRangeParams(), asset, totalAmount);
    }

    modifier totalAmountEqualToAmountsSum() {
        _;
    }

    function test_CreateWithRange() external totalAmountNotZero paramsCountNotZero totalAmountEqualToAmountsSum {
        uint256[] memory streamIds;

        expectTransferFromCall(users.sender, address(batch), DEFAULT_TOTAL_AMOUNT);
        expectTransferFromCallMutiple(address(batch), address(linear), DEFAULT_AMOUNT);

        streamIds = batch.createWithRangeMultiple(linear, defaultRangeParams(), asset, DEFAULT_TOTAL_AMOUNT);

        uint256 actualStreamIdsCount = streamIds.length;
        uint256 expectedStreamIdsCount = streamIds.length;

        assertEq(actualStreamIdsCount, expectedStreamIdsCount);
        assertEq(streamIds, DEFAULT_STREAM_IDS);
    }
}
