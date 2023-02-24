// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.18;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { ISablierV2Lockup } from "@sablier/v2-core/interfaces/ISablierV2Lockup.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/interfaces/ISablierV2LockupLinear.sol";
import { ISablierV2LockupPro } from "@sablier/v2-core/interfaces/ISablierV2LockupPro.sol";
import { LockupLinear, LockupPro } from "@sablier/v2-core/types/DataTypes.sol";

import { ISablierV2ProxyTarget } from "./interfaces/ISablierV2ProxyTarget.sol";
import { IWETH9 } from "./interfaces/IWETH9.sol";
import { Helpers } from "./libraries/Helpers.sol";
import { CreateLinear, CreatePro } from "./types/DataTypes.sol";

contract SablierV2ProxyTarget is ISablierV2ProxyTarget {
    /*//////////////////////////////////////////////////////////////////////////
                                 SABLIER-V2-LOCKUP
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2ProxyTarget
    function cancel(ISablierV2Lockup lockup, uint256 streamId) external {
        Helpers.cancel(lockup, streamId);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function cancelMultiple(ISablierV2Lockup lockup, IERC20 asset, uint256[] calldata streamIds) external {
        Helpers.cancelMultiple(lockup, asset, streamIds);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function renounce(ISablierV2Lockup lockup, uint256 streamId) external {
        lockup.renounce(streamId);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function withdraw(ISablierV2Lockup lockup, uint256 streamId, address to, uint128 amount) external {
        lockup.withdraw(streamId, to, amount);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function withdrawMax(ISablierV2Lockup lockup, uint256 streamId, address to) external {
        lockup.withdrawMax(streamId, to);
    }

    /*//////////////////////////////////////////////////////////////////////////
                              SABLIER-V2-LOCKUP-LINEAR
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2ProxyTarget
    function cancelAndCreateWithDurations(
        ISablierV2Lockup lockup,
        ISablierV2LockupLinear linear,
        uint256 streamId,
        LockupLinear.CreateWithDurations calldata params
    ) external override returns (uint256 newStreamId) {
        lockup.cancel(streamId);
        newStreamId = Helpers.createWithDurations(linear, params);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function cancelAndCreateWithRange(
        ISablierV2Lockup lockup,
        ISablierV2LockupLinear linear,
        uint256 streamId,
        LockupLinear.CreateWithRange calldata params
    ) external override returns (uint256 newStreamId) {
        lockup.cancel(streamId);
        newStreamId = Helpers.createWithRange(linear, params);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function createWithDurations(
        ISablierV2LockupLinear linear,
        LockupLinear.CreateWithDurations calldata params
    ) external override returns (uint256 streamId) {
        streamId = Helpers.createWithDurations(linear, params);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function createWithRange(
        ISablierV2LockupLinear linear,
        LockupLinear.CreateWithRange calldata params
    ) external override returns (uint256 streamId) {
        streamId = Helpers.createWithRange(linear, params);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function createWithDurationsMultiple(
        ISablierV2LockupLinear linear,
        CreateLinear.DurationsParams[] calldata params,
        IERC20 asset,
        uint128 totalAmount
    ) external override returns (uint256[] memory streamIds) {
        uint128 amountsSum;
        uint256 count = params.length;
        uint256 i;

        // Calculate the params amounts summed up.
        for (i = 0; i < count; ) {
            amountsSum += params[i].amount;
            unchecked {
                i += 1;
            }
        }

        // Checks: validate the arguments.
        Helpers.checkCreateMultipleParams(totalAmount, amountsSum);

        // Interactions: perform the ERC-20 transfer and approve the sablier contract to spend the amount of assets.
        Helpers.transferAndApprove(address(linear), asset, totalAmount);

        // Declare an array of `count` length to avoid "Index out of bounds error".
        uint256[] memory _streamIds = new uint256[](count);
        for (i = 0; i < count; ) {
            // Interactions: make the external call.
            _streamIds[i] = linear.createWithDurations(
                LockupLinear.CreateWithDurations({
                    asset: asset,
                    broker: params[i].broker,
                    cancelable: params[i].cancelable,
                    durations: params[i].durations,
                    recipient: params[i].recipient,
                    sender: params[i].sender,
                    totalAmount: params[i].amount
                })
            );

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
        }

        streamIds = _streamIds;
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function createWithRangeMultiple(
        ISablierV2LockupLinear linear,
        CreateLinear.RangeParams[] calldata params,
        IERC20 asset,
        uint128 totalAmount
    ) external override returns (uint256[] memory streamIds) {
        uint128 amountsSum;
        uint256 count = params.length;
        uint256 i;

        // Calculate the params amounts summed up.
        for (i = 0; i < count; ) {
            amountsSum += params[i].amount;
            unchecked {
                i += 1;
            }
        }

        // Checks: validate the arguments.
        Helpers.checkCreateMultipleParams(totalAmount, amountsSum);

        // Interactions: perform the ERC-20 transfer and approve the sablier contract to spend the amount of assets.
        Helpers.transferAndApprove(address(linear), asset, totalAmount);

        // Declare an array of `count` length to avoid "Index out of bounds error".
        uint256[] memory _streamIds = new uint256[](count);
        for (i = 0; i < count; ) {
            // Interactions: make the external call.
            _streamIds[i] = linear.createWithRange(
                LockupLinear.CreateWithRange({
                    asset: asset,
                    broker: params[i].broker,
                    cancelable: params[i].cancelable,
                    range: params[i].range,
                    recipient: params[i].recipient,
                    sender: params[i].sender,
                    totalAmount: params[i].amount
                })
            );

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
        }

        streamIds = _streamIds;
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function wrapEtherAndCreateWithDurations(
        IWETH9 weth9,
        ISablierV2LockupLinear linear,
        LockupLinear.CreateWithDurations calldata params
    ) external payable override returns (uint256 streamId) {
        // Checks and interactions: check the params and deposit the ether.
        Helpers.checkParamsAndDepositEther(weth9, params.asset, params.totalAmount);
        streamId = Helpers.createWithDurations(linear, params);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function wrapEtherAndCreateWithRange(
        IWETH9 weth9,
        ISablierV2LockupLinear linear,
        LockupLinear.CreateWithRange calldata params
    ) external payable override returns (uint256 streamId) {
        // Checks and interactions: check the params and deposit the ether.
        Helpers.checkParamsAndDepositEther(weth9, params.asset, params.totalAmount);
        streamId = Helpers.createWithRange(linear, params);
    }

    /*//////////////////////////////////////////////////////////////////////////
                               SABLIER-V2-LOCKUP-PRO
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2ProxyTarget
    function cancelAndCreateWithDeltas(
        ISablierV2Lockup lockup,
        ISablierV2LockupPro pro,
        uint256 streamId,
        LockupPro.CreateWithDeltas calldata params
    ) external override returns (uint256 newStreamId) {
        lockup.cancel(streamId);
        newStreamId = Helpers.createWithDeltas(pro, params);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function cancelAndCreateWithMilestones(
        ISablierV2Lockup lockup,
        ISablierV2LockupPro pro,
        uint256 streamId,
        LockupPro.CreateWithMilestones calldata params
    ) external override returns (uint256 newStreamId) {
        lockup.cancel(streamId);
        newStreamId = Helpers.createWithMilestones(pro, params);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function createWithDelta(
        ISablierV2LockupPro pro,
        LockupPro.CreateWithDeltas calldata params
    ) external override returns (uint256 streamId) {
        streamId = Helpers.createWithDeltas(pro, params);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function createWithMilestones(
        ISablierV2LockupPro pro,
        LockupPro.CreateWithMilestones calldata params
    ) external override returns (uint256 streamId) {
        streamId = Helpers.createWithMilestones(pro, params);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function createWithDeltasMultiple(
        ISablierV2LockupPro pro,
        CreatePro.DeltasParams[] calldata params,
        IERC20 asset,
        uint128 totalAmount
    ) external override returns (uint256[] memory streamIds) {
        uint128 amountsSum;
        uint256 count = params.length;
        uint256 i;

        // Calculate the params amounts summed up.
        for (i = 0; i < count; ) {
            amountsSum += params[i].amount;
            unchecked {
                i += 1;
            }
        }

        // Checks: validate the arguments.
        Helpers.checkCreateMultipleParams(totalAmount, amountsSum);

        // Interactions: perform the ERC-20 transfer and approve the sablier contract to spend the amount of assets.
        Helpers.transferAndApprove(address(pro), asset, totalAmount);

        // Declare an array of `count` length to avoid "Index out of bounds error".
        uint256[] memory _streamIds = new uint256[](count);
        for (i = 0; i < count; ) {
            // Interactions: make the external call.
            _streamIds[i] = pro.createWithDeltas(
                LockupPro.CreateWithDeltas({
                    asset: asset,
                    broker: params[i].broker,
                    cancelable: params[i].cancelable,
                    recipient: params[i].recipient,
                    segments: params[i].segments,
                    sender: params[i].sender,
                    totalAmount: params[i].amount
                })
            );

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
        }

        streamIds = _streamIds;
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function createWithMilestonesMultiple(
        ISablierV2LockupPro pro,
        CreatePro.MilestonesParams[] calldata params,
        IERC20 asset,
        uint128 totalAmount
    ) external override returns (uint256[] memory streamIds) {
        uint128 amountsSum;
        uint256 count = params.length;
        uint256 i;

        // Calculate the params amounts summed up.
        for (i = 0; i < count; ) {
            amountsSum += params[i].amount;
            unchecked {
                i += 1;
            }
        }

        // Checks: validate the arguments.
        Helpers.checkCreateMultipleParams(totalAmount, amountsSum);

        // Interactions: perform the ERC-20 transfer and approve the sablier contract to spend the amount of assets.
        Helpers.transferAndApprove(address(pro), asset, totalAmount);

        // Declare an array of `count` length to avoid "Index out of bounds error".
        uint256[] memory _streamIds = new uint256[](count);
        for (i = 0; i < count; ) {
            // Interactions: make the external call.
            _streamIds[i] = pro.createWithMilestones(
                LockupPro.CreateWithMilestones({
                    asset: asset,
                    broker: params[i].broker,
                    cancelable: params[i].cancelable,
                    recipient: params[i].recipient,
                    segments: params[i].segments,
                    sender: params[i].sender,
                    startTime: params[i].startTime,
                    totalAmount: params[i].amount
                })
            );

            // Increment the for loop iterator.
            unchecked {
                i += 1;
            }
        }

        streamIds = _streamIds;
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function wrapEtherAndCreateWithDeltas(
        IWETH9 weth9,
        ISablierV2LockupPro pro,
        LockupPro.CreateWithDeltas calldata params
    ) external payable override returns (uint256 streamId) {
        // Checks and interactions: check the params and deposit the ether.
        Helpers.checkParamsAndDepositEther(weth9, params.asset, params.totalAmount);
        streamId = Helpers.createWithDeltas(pro, params);
    }

    /// @inheritdoc ISablierV2ProxyTarget
    function wrapEtherAndCreateWithMilestones(
        IWETH9 weth9,
        ISablierV2LockupPro pro,
        LockupPro.CreateWithMilestones calldata params
    ) external payable override returns (uint256 streamId) {
        // Checks and interactions: check the params and deposit the ether.
        Helpers.checkParamsAndDepositEther(weth9, params.asset, params.totalAmount);
        streamId = Helpers.createWithMilestones(pro, params);
    }
}
