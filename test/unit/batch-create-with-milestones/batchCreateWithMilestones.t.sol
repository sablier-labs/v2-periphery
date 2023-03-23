// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Errors } from "src/libraries/Errors.sol";
import { Batch } from "src/types/DataTypes.sol";

import { Unit_Test } from "../Unit.t.sol";
import { DefaultParams } from "../../helpers/DefaultParams.t.sol";

contract BatchCreateWithMilestones_Test is Unit_Test {
    function setUp() public virtual override {
        Unit_Test.setUp();

        changePrank(users.sender);
    }

    /// @dev it should revert.
    function test_RevertWhen_TotalAmountZero() external {
        uint128 totalAmountZero = 0;
        bytes memory data = abi.encodeCall(
            target.batchCreateWithMilestones,
            (
                dynamic,
                asset,
                totalAmountZero,
                DefaultParams.batchCreateWithMilestones(users, address(proxy)),
                permit2Params()
            )
        );
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2ProxyTarget_TotalAmountZero.selector));
        proxy.execute(address(target), data);
    }

    modifier whenTotalAmountNotZero() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_ParamsCountZero() external whenTotalAmountNotZero {
        Batch.CreateWithMilestones[] memory params;
        bytes memory data = abi.encodeCall(
            target.batchCreateWithMilestones, (dynamic, asset, DefaultParams.TOTAL_AMOUNT, params, permit2Params())
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierV2ProxyTarget_TotalAmountNotEqualToAmountsSum.selector, DefaultParams.TOTAL_AMOUNT, 0
            )
        );
        proxy.execute(address(target), data);
    }

    modifier whenParamsCountNotZero() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_TotalAmountNotEqualToAmountsSum() external whenTotalAmountNotZero whenParamsCountNotZero {
        uint128 totalAmount = DefaultParams.TOTAL_AMOUNT - 1;
        bytes memory data = abi.encodeCall(
            target.batchCreateWithMilestones,
            (
                dynamic,
                asset,
                totalAmount,
                DefaultParams.batchCreateWithMilestones(users, address(proxy)),
                permit2Params()
            )
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierV2ProxyTarget_TotalAmountNotEqualToAmountsSum.selector,
                totalAmount,
                DefaultParams.TOTAL_AMOUNT
            )
        );
        proxy.execute(address(target), data);
    }

    modifier whenTotalAmountEqualToAmountsSum() {
        _;
    }

    /// @dev it should create multiple streams.
    function test_BatchCreateWithMilestones()
        external
        whenTotalAmountNotZero
        whenParamsCountNotZero
        whenTotalAmountEqualToAmountsSum
    {
        expectTransferFromCall(users.sender, address(proxy), DefaultParams.TOTAL_AMOUNT);
        expectMutipleTransferFromCalls(address(proxy), address(dynamic), DefaultParams.AMOUNT);

        uint256[] memory streamIds = batchCreateWithMilestonesDefault();

        assertEq(streamIds, DefaultParams.streamIds());
    }
}
