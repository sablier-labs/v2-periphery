// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
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
        YieldMode actualYieldMode;
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
        YieldMode expectedYieldMode;
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

        // Blast configuration
        vars.actualBlastYieldMode = YieldMode(blastMock.readYieldConfiguration(address(constructedStreamerLL)));
        vars.expectedBlastYieldMode = YieldMode.VOID;
        assertEq(uint8(vars.actualBlastYieldMode), uint8(vars.expectedBlastYieldMode), "blastYieldMode");

        (,,, vars.actualBlastGasMode) = blastMock.readGasParams(address(constructedStreamerLL));
        vars.expectedBlastGasMode = GasMode.VOID;
        assertEq(uint8(vars.actualBlastGasMode), uint8(vars.expectedBlastGasMode), "blastGasMode");

        vars.actualBlastGovernor = blastMock.governorMap(address(constructedStreamerLL));
        vars.expectedBlastGovernor = address(0);
        assertEq(vars.actualBlastGovernor, vars.expectedBlastGovernor, "blastGovernor");
    }

    function test_ConstructorWhen_RebasingAsset() external {
        SablierV2MerkleStreamerLL constructedStreamerLL = new SablierV2MerkleStreamerLL(
            users.admin,
            lockupLinear,
            IERC20(address(erc20RebasingMock)),
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
        vars.expectedAsset = address(erc20RebasingMock);
        assertEq(vars.actualAsset, vars.expectedAsset, "erc20RebasingMock");

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

        vars.actualAllowance =
            IERC20(address(erc20RebasingMock)).allowance(address(constructedStreamerLL), address(lockupLinear));
        vars.expectedAllowance = MAX_UINT256;
        assertEq(vars.actualAllowance, vars.expectedAllowance, "allowance");

        // Blast configuration
        vars.actualBlastYieldMode = YieldMode(blastMock.readYieldConfiguration(address(constructedStreamerLL)));
        vars.expectedBlastYieldMode = YieldMode.VOID;
        assertEq(uint8(vars.actualBlastYieldMode), uint8(vars.expectedBlastYieldMode), "blastYieldMode");

        (,,, vars.actualBlastGasMode) = blastMock.readGasParams(address(constructedStreamerLL));
        vars.expectedBlastGasMode = GasMode.VOID;
        assertEq(uint8(vars.actualBlastGasMode), uint8(vars.expectedBlastGasMode), "blastGasMode");

        vars.actualBlastGovernor = blastMock.governorMap(address(constructedStreamerLL));
        vars.expectedBlastGovernor = address(0);
        assertEq(vars.actualBlastGovernor, vars.expectedBlastGovernor, "blastGovernor");

        vars.actualYieldMode = erc20RebasingMock.getConfiguration(address(constructedStreamerLL));
        vars.expectedYieldMode = YieldMode.AUTOMATIC;
        assertEq(uint8(vars.actualYieldMode), uint8(vars.expectedYieldMode));
    }
}
