// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ISablierV2ProxyTarget } from "src/interfaces/ISablierV2ProxyTarget.sol";

import { Integration_Test } from "../../Integration.t.sol";
import { BatchCancelMultiple_Integration_Test } from "../shared/batch-cancel-multiple/batchCancelMultiple.t.sol";
import { BatchCreateWithDeltas_Integration_Test } from "../shared/batch-create-with-deltas/batchCreateWithDeltas.t.sol";
import { BatchCreateWithDurations_Integration_Test } from
    "../shared/batch-create-with-durations/batchCreateWithDurations.t.sol";
import { BatchCreateWithMilestones_Integration_Test } from
    "../shared/batch-create-with-milestones/batchCreateWithMilestones.t.sol";
import { BatchCreateWithRange_Integration_Test } from "../shared/batch-create-with-range/batchCreateWithRange.t.sol";
import { Burn_Integration_Test } from "../shared/burn/burn.t.sol";
import { Cancel_Integration_Test } from "../shared/cancel/cancel.t.sol";
import { CancelAndCreate_Integration_Test } from "../shared/cancel-and-create/cancelAndCreate.t.sol";
import { CancelMultiple_Integration_Test } from "../shared/cancel-multiple/cancelMultiple.t.sol";
import { Renounce_Integration_Test } from "../shared/renounce/renounce.t.sol";
import { Withdraw_Integration_Test } from "../shared/withdraw/withdraw.t.sol";
import { WithdrawMax_Integration_Test } from "../shared/withdraw-max/withdrawMax.t.sol";
import { WithdrawMaxAndTransfer_Integration_Test } from
    "../shared/withdraw-max-and-transfer/withdrawMaxAndTransfer.t.sol";
import { WithdrawMultiple_Integration_Test } from "../shared/withdraw-multiple/withdrawMultiple.t.sol";
import { WrapAndCreate_Integration_Test } from "../shared/wrap-and-create/wrapAndCreate.t.sol";

abstract contract ProxyTargetPermit2_Integration_Test is Integration_Test {
    function setUp() public virtual override {
        Integration_Test.setUp();
        target = ISablierV2ProxyTarget(targetPermit2);
        changePrank({ msgSender: users.alice.addr });
    }
}

contract BatchCancelMultiple_ProxyTargetPermit2_Integration_Test is
    ProxyTargetPermit2_Integration_Test,
    BatchCancelMultiple_Integration_Test
{
    function setUp()
        public
        virtual
        override(ProxyTargetPermit2_Integration_Test, BatchCancelMultiple_Integration_Test)
    {
        ProxyTargetPermit2_Integration_Test.setUp();
        BatchCancelMultiple_Integration_Test.setUp();
    }
}

contract BatchCreateWithDeltas_ProxyTargetPermit2_Integration_Test is
    ProxyTargetPermit2_Integration_Test,
    BatchCreateWithDeltas_Integration_Test
{
    function setUp()
        public
        virtual
        override(ProxyTargetPermit2_Integration_Test, BatchCreateWithDeltas_Integration_Test)
    {
        ProxyTargetPermit2_Integration_Test.setUp();
        BatchCreateWithDeltas_Integration_Test.setUp();
    }
}

contract BatchCreateWithDurations_ProxyTargetPermit2_Integration_Test is
    ProxyTargetPermit2_Integration_Test,
    BatchCreateWithDurations_Integration_Test
{
    function setUp()
        public
        virtual
        override(ProxyTargetPermit2_Integration_Test, BatchCreateWithDurations_Integration_Test)
    {
        ProxyTargetPermit2_Integration_Test.setUp();
        BatchCreateWithDurations_Integration_Test.setUp();
    }
}

contract BatchCreateWithMilestones_ProxyTargetPermit2_Integration_Test is
    ProxyTargetPermit2_Integration_Test,
    BatchCreateWithMilestones_Integration_Test
{
    function setUp()
        public
        virtual
        override(ProxyTargetPermit2_Integration_Test, BatchCreateWithMilestones_Integration_Test)
    {
        ProxyTargetPermit2_Integration_Test.setUp();
        BatchCreateWithMilestones_Integration_Test.setUp();
    }
}

contract BatchCreateWithRange_ProxyTargetPermit2_Integration_Test is
    ProxyTargetPermit2_Integration_Test,
    BatchCreateWithRange_Integration_Test
{
    function setUp()
        public
        virtual
        override(ProxyTargetPermit2_Integration_Test, BatchCreateWithRange_Integration_Test)
    {
        ProxyTargetPermit2_Integration_Test.setUp();
        BatchCreateWithRange_Integration_Test.setUp();
    }
}

contract Burn_ProxyTargetPermit2_Integration_Test is ProxyTargetPermit2_Integration_Test, Burn_Integration_Test {
    function setUp() public virtual override(ProxyTargetPermit2_Integration_Test, Burn_Integration_Test) {
        ProxyTargetPermit2_Integration_Test.setUp();
        Burn_Integration_Test.setUp();
    }
}

contract Cancel_ProxyTargetPermit2_Integration_Test is ProxyTargetPermit2_Integration_Test, Cancel_Integration_Test {
    function setUp() public virtual override(ProxyTargetPermit2_Integration_Test, Cancel_Integration_Test) {
        ProxyTargetPermit2_Integration_Test.setUp();
        Cancel_Integration_Test.setUp();
    }
}

contract CancelAndCreate_ProxyTargetPermit2_Integration_Test is
    ProxyTargetPermit2_Integration_Test,
    CancelAndCreate_Integration_Test
{
    function setUp() public virtual override(ProxyTargetPermit2_Integration_Test, CancelAndCreate_Integration_Test) {
        ProxyTargetPermit2_Integration_Test.setUp();
        CancelAndCreate_Integration_Test.setUp();
    }
}

contract CancelMultiple_ProxyTargetPermit2_Integration_Test is
    ProxyTargetPermit2_Integration_Test,
    CancelMultiple_Integration_Test
{
    function setUp() public virtual override(ProxyTargetPermit2_Integration_Test, CancelMultiple_Integration_Test) {
        ProxyTargetPermit2_Integration_Test.setUp();
        CancelMultiple_Integration_Test.setUp();
    }
}

contract Renounce_ProxyTargetPermit2_Integration_Test is
    ProxyTargetPermit2_Integration_Test,
    Renounce_Integration_Test
{
    function setUp() public virtual override(ProxyTargetPermit2_Integration_Test, Renounce_Integration_Test) {
        ProxyTargetPermit2_Integration_Test.setUp();
        Renounce_Integration_Test.setUp();
    }
}

contract Withdraw_ProxyTargetPermit2_Integration_Test is
    ProxyTargetPermit2_Integration_Test,
    Withdraw_Integration_Test
{
    function setUp() public virtual override(ProxyTargetPermit2_Integration_Test, Withdraw_Integration_Test) {
        ProxyTargetPermit2_Integration_Test.setUp();
        Withdraw_Integration_Test.setUp();
    }
}

contract WithdrawMax_ProxyTargetPermit2_Integration_Test is
    ProxyTargetPermit2_Integration_Test,
    WithdrawMax_Integration_Test
{
    function setUp() public virtual override(ProxyTargetPermit2_Integration_Test, WithdrawMax_Integration_Test) {
        ProxyTargetPermit2_Integration_Test.setUp();
        WithdrawMax_Integration_Test.setUp();
    }
}

contract WithdrawMaxAndTransfer_ProxyTargetPermit2_Integration_Test is
    ProxyTargetPermit2_Integration_Test,
    WithdrawMaxAndTransfer_Integration_Test
{
    function setUp()
        public
        virtual
        override(ProxyTargetPermit2_Integration_Test, WithdrawMaxAndTransfer_Integration_Test)
    {
        ProxyTargetPermit2_Integration_Test.setUp();
        WithdrawMaxAndTransfer_Integration_Test.setUp();
    }
}

contract WithdrawMultiple_ProxyTargetPermit2_Integration_Test is
    ProxyTargetPermit2_Integration_Test,
    WithdrawMultiple_Integration_Test
{
    function setUp() public virtual override(ProxyTargetPermit2_Integration_Test, WithdrawMultiple_Integration_Test) {
        ProxyTargetPermit2_Integration_Test.setUp();
        WithdrawMultiple_Integration_Test.setUp();
    }
}

contract WrapAndCreate_ProxyTargetPermit2_Integration_Test is
    ProxyTargetPermit2_Integration_Test,
    WrapAndCreate_Integration_Test
{
    function setUp() public virtual override(ProxyTargetPermit2_Integration_Test, WrapAndCreate_Integration_Test) {
        ProxyTargetPermit2_Integration_Test.setUp();
        WrapAndCreate_Integration_Test.setUp();
    }
}
