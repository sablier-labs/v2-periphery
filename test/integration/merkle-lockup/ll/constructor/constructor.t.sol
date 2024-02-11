// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { SablierV2MerkleLockupLL } from "src/SablierV2MerkleLockupLL.sol";

import { MerkleLockup_Integration_Test } from "../../MerkleLockup.t.sol";

contract Constructor_MerkleLockupLL_Integration_Test is MerkleLockup_Integration_Test {
    /// @dev Needed to prevent "Stack too deep" error
    struct Vars {
        address actualAdmin;
        uint256 actualAllowance;
        address actualAsset;
        string actualName;
        bool actualCancelable;
        bool actualTransferable;
        LockupLinear.Durations actualDurations;
        uint40 actualExpiration;
        address actualLockupLinear;
        bytes32 actualMerkleRoot;
        address expectedAdmin;
        uint256 expectedAllowance;
        address expectedAsset;
        bytes32 expectedName;
        bool expectedCancelable;
        bool expectedTransferable;
        LockupLinear.Durations expectedDurations;
        uint40 expectedExpiration;
        address expectedLockupLinear;
        bytes32 expectedMerkleRoot;
    }

    function test_Constructor() external {
        SablierV2MerkleLockupLL constructedLockupLL =
            new SablierV2MerkleLockupLL(defaults.baseParams(), lockupLinear, defaults.durations());

        Vars memory vars;

        vars.actualAdmin = constructedLockupLL.admin();
        vars.expectedAdmin = users.admin;
        assertEq(vars.actualAdmin, vars.expectedAdmin, "admin");

        vars.actualAsset = address(constructedLockupLL.ASSET());
        vars.expectedAsset = address(dai);
        assertEq(vars.actualAsset, vars.expectedAsset, "asset");

        vars.actualName = constructedLockupLL.name();
        vars.expectedName = defaults.NAME_BYTES32();
        assertEq(bytes32(abi.encodePacked(vars.actualName)), vars.expectedName, "name");

        vars.actualMerkleRoot = constructedLockupLL.MERKLE_ROOT();
        vars.expectedMerkleRoot = defaults.MERKLE_ROOT();
        assertEq(vars.actualMerkleRoot, vars.expectedMerkleRoot, "merkleRoot");

        vars.actualCancelable = constructedLockupLL.CANCELABLE();
        vars.expectedCancelable = defaults.CANCELABLE();
        assertEq(vars.actualCancelable, vars.expectedCancelable, "cancelable");

        vars.actualTransferable = constructedLockupLL.TRANSFERABLE();
        vars.expectedTransferable = defaults.TRANSFERABLE();
        assertEq(vars.actualTransferable, vars.expectedTransferable, "transferable");

        vars.actualExpiration = constructedLockupLL.EXPIRATION();
        vars.expectedExpiration = defaults.EXPIRATION();
        assertEq(vars.actualExpiration, vars.expectedExpiration, "expiration");

        vars.actualLockupLinear = address(constructedLockupLL.LOCKUP_LINEAR());
        vars.expectedLockupLinear = address(lockupLinear);
        assertEq(vars.actualLockupLinear, vars.expectedLockupLinear, "lockupLinear");

        (vars.actualDurations.cliff, vars.actualDurations.total) = constructedLockupLL.streamDurations();
        vars.expectedDurations = defaults.durations();
        assertEq(vars.actualDurations.cliff, vars.expectedDurations.cliff, "durations.cliff");
        assertEq(vars.actualDurations.total, vars.expectedDurations.total, "durations.total");

        vars.actualAllowance = dai.allowance(address(constructedLockupLL), address(lockupLinear));
        vars.expectedAllowance = MAX_UINT256;
        assertEq(vars.actualAllowance, vars.expectedAllowance, "allowance");
    }
}
