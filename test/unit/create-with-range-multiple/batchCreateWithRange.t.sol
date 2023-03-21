// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Errors } from "src/libraries/Errors.sol";
import { Batch } from "src/types/DataTypes.sol";

import { Unit_Test } from "../Unit.t.sol";

contract batchCreateWithRange_Test is Unit_Test {
    function setUp() public virtual override {
        Unit_Test.setUp();

        changePrank(users.sender);
    }

    /// @dev it should revert.
    function test_RevertWhen_TotalAmountZero() external {
        uint128 totalAmountZero = 0;
        // Expect a {SablierV2ProxyTarget_TotalAmountZero} error.
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2ProxyTarget_TotalAmountZero.selector));
        target.batchCreateWithRange(linear, asset, totalAmountZero, defaultRangeParams(), defaultPermit2Params);
    }

    modifier totalAmountNotZero() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_ParamsCountZero() external totalAmountNotZero {
        Batch.CreateWithRange[] memory params;
        // Expect a {SablierV2ProxyTarget_TotalAmountNotEqualToAmountsSum} error.
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierV2ProxyTarget_TotalAmountNotEqualToAmountsSum.selector, DEFAULT_TOTAL_AMOUNT, 0
            )
        );
        target.batchCreateWithRange(linear, asset, DEFAULT_TOTAL_AMOUNT, params, defaultPermit2Params);
    }

    modifier paramsCountNotZero() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_TotalAmountNotEqualToAmountsSum() external totalAmountNotZero paramsCountNotZero {
        uint128 totalAmount = DEFAULT_TOTAL_AMOUNT - 1;
        // Expect a {SablierV2ProxyTarget_TotalAmountNotEqualToAmountsSum} error.
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierV2ProxyTarget_TotalAmountNotEqualToAmountsSum.selector, totalAmount, DEFAULT_TOTAL_AMOUNT
            )
        );
        target.batchCreateWithRange(linear, asset, totalAmount, defaultRangeParams(), defaultPermit2Params);
    }

    modifier totalAmountEqualToAmountsSum() {
        _;
    }

    function test_CreateWithRange() external totalAmountNotZero paramsCountNotZero totalAmountEqualToAmountsSum {
        expectTransferFromCall(users.sender, address(target), DEFAULT_TOTAL_AMOUNT);
        expectTransferFromCallMutiple(address(target), address(linear), DEFAULT_AMOUNT);

        uint256[] memory streamIds = batchCreateWithRangeDefault();

        uint256 actualStreamIdsCount = streamIds.length;
        uint256 expectedStreamIdsCount = streamIds.length;

        assertEq(actualStreamIdsCount, expectedStreamIdsCount);
        assertEq(streamIds, DEFAULT_STREAM_IDS);
    }
}
