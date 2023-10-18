// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20 <0.9.0;

import { LockupDynamic, LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { Integration_Test } from "../Integration.t.sol";

abstract contract Target_Integration_Test is Integration_Test {
    function setUp() public virtual override {
        Integration_Test.setUp();
    }

    function batchCreateWithDeltas() internal returns (uint256[] memory) {
        bytes memory data = abi.encodeCall(
            target.batchCreateWithDeltas,
            (lockupDynamic, asset, defaults.batchCreateWithDeltas(), getTransferData(defaults.TOTAL_TRANSFER_AMOUNT()))
        );
        bytes memory response = aliceProxy.execute(address(target), data);
        return abi.decode(response, (uint256[]));
    }

    function batchCreateWithDurations() internal returns (uint256[] memory) {
        bytes memory data = abi.encodeCall(
            target.batchCreateWithDurations,
            (
                lockupLinear,
                asset,
                defaults.batchCreateWithDurations(),
                getTransferData(defaults.TOTAL_TRANSFER_AMOUNT())
            )
        );
        bytes memory response = aliceProxy.execute(address(target), data);
        return abi.decode(response, (uint256[]));
    }

    function batchCreateWithMilestones() internal returns (uint256[] memory) {
        bytes memory data = abi.encodeCall(
            target.batchCreateWithMilestones,
            (
                lockupDynamic,
                asset,
                defaults.batchCreateWithMilestones(),
                getTransferData(defaults.TOTAL_TRANSFER_AMOUNT())
            )
        );
        bytes memory response = aliceProxy.execute(address(target), data);
        return abi.decode(response, (uint256[]));
    }

    function batchCreateWithMilestones(uint256 batchSize) internal returns (uint256[] memory) {
        uint128 totalTransferAmount = uint128(batchSize) * defaults.PER_STREAM_AMOUNT();
        bytes memory data = abi.encodeCall(
            target.batchCreateWithMilestones,
            (lockupDynamic, asset, defaults.batchCreateWithMilestones(batchSize), getTransferData(totalTransferAmount))
        );
        bytes memory response = aliceProxy.execute(address(target), data);
        return abi.decode(response, (uint256[]));
    }

    function batchCreateWithRange() internal returns (uint256[] memory) {
        bytes memory data = abi.encodeCall(
            target.batchCreateWithRange,
            (lockupLinear, asset, defaults.batchCreateWithRange(), getTransferData(defaults.TOTAL_TRANSFER_AMOUNT()))
        );
        bytes memory response = aliceProxy.execute(address(target), data);
        return abi.decode(response, (uint256[]));
    }

    function batchCreateWithRange(uint256 batchSize) internal returns (uint256[] memory) {
        uint128 totalTransferAmount = uint128(batchSize) * defaults.PER_STREAM_AMOUNT();
        bytes memory data = abi.encodeCall(
            target.batchCreateWithRange,
            (lockupLinear, asset, defaults.batchCreateWithRange(batchSize), getTransferData(totalTransferAmount))
        );
        bytes memory response = aliceProxy.execute(address(target), data);
        return abi.decode(response, (uint256[]));
    }

    function createWithDeltas() internal returns (uint256) {
        bytes memory data = abi.encodeCall(
            target.createWithDeltas,
            (lockupDynamic, defaults.createWithDeltas(), getTransferData(defaults.PER_STREAM_AMOUNT()))
        );
        bytes memory response = aliceProxy.execute(address(target), data);
        return abi.decode(response, (uint256));
    }

    function createWithDurations() internal returns (uint256) {
        bytes memory data = abi.encodeCall(
            target.createWithDurations,
            (lockupLinear, defaults.createWithDurations(), getTransferData(defaults.PER_STREAM_AMOUNT()))
        );
        bytes memory response = aliceProxy.execute(address(target), data);
        return abi.decode(response, (uint256));
    }

    function createWithMilestones() internal returns (uint256) {
        bytes memory data = abi.encodeCall(
            target.createWithMilestones,
            (lockupDynamic, defaults.createWithMilestones(), getTransferData(defaults.PER_STREAM_AMOUNT()))
        );
        bytes memory response = aliceProxy.execute(address(target), data);
        return abi.decode(response, (uint256));
    }

    function createWithMilestones(LockupDynamic.CreateWithMilestones memory params) internal returns (uint256) {
        bytes memory data = abi.encodeCall(
            target.createWithMilestones, (lockupDynamic, params, getTransferData(defaults.PER_STREAM_AMOUNT()))
        );
        bytes memory response = aliceProxy.execute(address(target), data);
        return abi.decode(response, (uint256));
    }

    function createWithRange() internal returns (uint256) {
        bytes memory data = abi.encodeCall(
            target.createWithRange,
            (lockupLinear, defaults.createWithRange(), getTransferData(defaults.PER_STREAM_AMOUNT()))
        );
        bytes memory response = aliceProxy.execute(address(target), data);
        return abi.decode(response, (uint256));
    }

    function createWithRange(LockupLinear.CreateWithRange memory params) internal returns (uint256) {
        bytes memory data = abi.encodeCall(
            target.createWithRange, (lockupLinear, params, getTransferData(defaults.PER_STREAM_AMOUNT()))
        );
        bytes memory response = aliceProxy.execute(address(target), data);
        return abi.decode(response, (uint256));
    }

    function getTransferData(uint160 amount) internal view returns (bytes memory) {
        if (target == targetPermit2) {
            return defaults.permit2Params(amount);
        }
        // The {ProxyTargetApprove} contract does not require any transfer data.
        return bytes("");
    }
}
