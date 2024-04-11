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
        string actualIpfsCID;
        string actualName;
        bool actualCancelable;
        LockupLinear.Durations actualDurations;
        uint40 actualExpiration;
        address actualLockupLinear;
        bytes32 actualMerkleRoot;
        bool actualTransferable;
        address expectedAdmin;
        uint256 expectedAllowance;
        address expectedAsset;
        bool expectedCancelable;
        LockupLinear.Durations expectedDurations;
        uint40 expectedExpiration;
        string expectedIpfsCID;
        address expectedLockupLinear;
        bytes32 expectedMerkleRoot;
        bytes32 expectedName;
        bool expectedTransferable;
    }

    function test_Constructor() external {
        SablierV2MerkleLockupLL constructedLockupLL =
            new SablierV2MerkleLockupLL(defaults.baseParams(), lockupLinear, defaults.durations());

        Vars memory vars;

        vars.actualAdmin = constructedLockupLL.admin();
        vars.expectedAdmin = users.admin;
        assertEq(vars.actualAdmin, vars.expectedAdmin, "admin");

        vars.actualAllowance = dai.allowance(address(constructedLockupLL), address(lockupLinear));
        vars.expectedAllowance = MAX_UINT256;
        assertEq(vars.actualAllowance, vars.expectedAllowance, "allowance");

        vars.actualAsset = address(constructedLockupLL.ASSET());
        vars.expectedAsset = address(dai);
        assertEq(vars.actualAsset, vars.expectedAsset, "asset");

        vars.actualCancelable = constructedLockupLL.CANCELABLE();
        vars.expectedCancelable = defaults.CANCELABLE();
        assertEq(vars.actualCancelable, vars.expectedCancelable, "cancelable");

        (vars.actualDurations.cliff, vars.actualDurations.total) = constructedLockupLL.streamDurations();
        vars.expectedDurations = defaults.durations();
        assertEq(vars.actualDurations.cliff, vars.expectedDurations.cliff, "durations.cliff");
        assertEq(vars.actualDurations.total, vars.expectedDurations.total, "durations.total");

        vars.actualExpiration = constructedLockupLL.EXPIRATION();
        vars.expectedExpiration = defaults.EXPIRATION();
        assertEq(vars.actualExpiration, vars.expectedExpiration, "expiration");

        vars.actualIpfsCID = constructedLockupLL.ipfsCID();
        vars.expectedIpfsCID = defaults.IPFS_CID();
        assertEq(vars.actualIpfsCID, vars.expectedIpfsCID, "ipfsCID");

        vars.actualLockupLinear = address(constructedLockupLL.LOCKUP_LINEAR());
        vars.expectedLockupLinear = address(lockupLinear);
        assertEq(vars.actualLockupLinear, vars.expectedLockupLinear, "lockupLinear");

        vars.actualMerkleRoot = constructedLockupLL.MERKLE_ROOT();
        vars.expectedMerkleRoot = defaults.MERKLE_ROOT();
        assertEq(vars.actualMerkleRoot, vars.expectedMerkleRoot, "merkleRoot");

        vars.actualName = constructedLockupLL.name();
        vars.expectedName = defaults.NAME_BYTES32();
        assertEq(bytes32(abi.encodePacked(vars.actualName)), vars.expectedName, "name");

        vars.actualTransferable = constructedLockupLL.TRANSFERABLE();
        vars.expectedTransferable = defaults.TRANSFERABLE();
        assertEq(vars.actualTransferable, vars.expectedTransferable, "transferable");
    }
}
