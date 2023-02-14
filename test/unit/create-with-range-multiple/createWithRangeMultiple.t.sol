// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <0.9.0;

import { Errors } from "src/libraries/Errors.sol";
import { CreateLinear } from "src/types/DataTypes.sol";

import { Unit_Test } from "../Unit.t.sol";

contract CreateWithRangeMultiple_Test is Unit_Test {
    uint256[] internal streamIds;

    function setUp() public virtual override {
        Unit_Test.setUp();
        streamIds = createWithRangeMultipleDefault();
    }

    /// @dev it should revert.
    function test_RevertWhen_TotalAmountZero() external {
        uint128 totalAmountZero = 0;
        // Expect a {BatchStream_TotalAmountZero} error.
        vm.expectRevert(abi.encodeWithSelector(Errors.BatchStream_TotalAmountZero.selector));
        batch.createWithRangeMultiple(linear, defaultRangeParams(), asset, totalAmountZero);
    }

    modifier TotalAmountNotZero() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_ParamsCountZero() external TotalAmountNotZero {
        CreateLinear.RangeParams[] memory params;
        // Expect a {BatchStream_ParamsCountZero} error.
        vm.expectRevert(abi.encodeWithSelector(Errors.BatchStream_ParamsCountZero.selector));
        batch.createWithRangeMultiple(linear, params, asset, DEFAULT_TOTAL_AMOUNT);
    }

    modifier ParamsCountNotZero() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_TotalAmountNotEqualToAmountsSum() external TotalAmountNotZero ParamsCountNotZero {
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
}
