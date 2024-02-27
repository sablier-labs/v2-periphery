// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { GasMode, YieldMode } from "@sablier/v2-core/src/interfaces/blast/IBlast.sol";
import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { SablierV2MerkleStreamerLL } from "src/SablierV2MerkleStreamerLL.sol";

import { MerkleStreamer_Integration_Test } from "../../MerkleStreamer.t.sol";

contract Constructor_MerkleStreamerLL_Integration_Test is MerkleStreamer_Integration_Test {
    /// @dev Needed to prevent "Stack too deep" error
    struct Vars {
        address actualAdmin;
        uint256 actualAllowance;
        address actualAsset;
        YieldMode actualBlastYieldMode;
        GasMode actualBlastGasMode;
        address actualBlastGovernor;
        bool actualCancelable;
        bool actualTransferable;
        LockupLinear.Durations actualDurations;
        uint40 actualExpiration;
        address actualLockupLinear;
        bytes32 actualMerkleRoot;
        address expectedAdmin;
        uint256 expectedAllowance;
        address expectedAsset;
        YieldMode expectedBlastYieldMode;
        GasMode expectedBlastGasMode;
        address expectedBlastGovernor;
        bool expectedCancelable;
        bool expectedTransferable;
        LockupLinear.Durations expectedDurations;
        uint40 expectedExpiration;
        address expectedLockupLinear;
        bytes32 expectedMerkleRoot;
    }

    function test_Constructor() external {
        SablierV2MerkleStreamerLL constructedStreamerLL = new SablierV2MerkleStreamerLL(
            users.admin,
            lockupLinear,
            dai,
            defaults.MERKLE_ROOT(),
            defaults.EXPIRATION(),
            defaults.durations(),
            defaults.CANCELABLE(),
            defaults.TRANSFERABLE()
        );

        Vars memory vars;

        vars.actualAdmin = constructedStreamerLL.admin();
        vars.expectedAdmin = users.admin;
        assertEq(vars.actualAdmin, vars.expectedAdmin, "admin");

        vars.actualAsset = address(constructedStreamerLL.ASSET());
        vars.expectedAsset = address(dai);
        assertEq(vars.actualAsset, vars.expectedAsset, "dai");

        vars.actualMerkleRoot = constructedStreamerLL.MERKLE_ROOT();
        vars.expectedMerkleRoot = defaults.MERKLE_ROOT();
        assertEq(vars.actualMerkleRoot, vars.expectedMerkleRoot, "merkleRoot");

        vars.actualCancelable = constructedStreamerLL.CANCELABLE();
        vars.expectedCancelable = defaults.CANCELABLE();
        assertEq(vars.actualCancelable, vars.expectedCancelable, "cancelable");

        vars.actualTransferable = constructedStreamerLL.TRANSFERABLE();
        vars.expectedTransferable = defaults.TRANSFERABLE();
        assertEq(vars.actualTransferable, vars.expectedTransferable, "transferable");

        vars.actualExpiration = constructedStreamerLL.EXPIRATION();
        vars.expectedExpiration = defaults.EXPIRATION();
        assertEq(vars.actualExpiration, vars.expectedExpiration, "expiration");

        vars.actualLockupLinear = address(constructedStreamerLL.LOCKUP_LINEAR());
        vars.expectedLockupLinear = address(lockupLinear);
        assertEq(vars.actualLockupLinear, vars.expectedLockupLinear, "lockupLinear");

        (vars.actualDurations.cliff, vars.actualDurations.total) = constructedStreamerLL.streamDurations();
        vars.expectedDurations = defaults.durations();
        assertEq(vars.actualDurations.cliff, vars.expectedDurations.cliff, "durations.cliff");
        assertEq(vars.actualDurations.total, vars.expectedDurations.total, "durations.total");

        vars.actualAllowance = dai.allowance(address(constructedStreamerLL), address(lockupLinear));
        vars.expectedAllowance = MAX_UINT256;
        assertEq(vars.actualAllowance, vars.expectedAllowance, "allowance");

        vars.actualBlastYieldMode = YieldMode(blastMock.readYieldConfiguration(address(constructedStreamerLL)));
        vars.expectedBlastYieldMode = YieldMode.VOID;
        assertEq(uint8(vars.actualBlastYieldMode), uint8(vars.expectedBlastYieldMode), "blastYieldMode");

        (,,, vars.actualBlastGasMode) = blastMock.readGasParams(address(constructedStreamerLL));
        vars.expectedBlastGasMode = GasMode.CLAIMABLE;
        assertEq(uint8(vars.actualBlastGasMode), uint8(vars.expectedBlastGasMode), "blastGasMode");

        vars.actualBlastGovernor = blastMock.governorMap(address(constructedStreamerLL));
        vars.expectedBlastGovernor = users.admin;
        assertEq(vars.actualBlastGovernor, vars.expectedBlastGovernor, "blastGovernor");
    }
}
