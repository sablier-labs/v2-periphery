// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { SablierV2AirstreamCampaignLL } from "src/SablierV2AirstreamCampaignLL.sol";

import { Integration_Test } from "../../../Integration.t.sol";

contract Constructor_CampaignLL_Integration_Test is Integration_Test {
    /// @dev Needed to prevent "Stack too deep" error
    struct Vars {
        address actualAdmin;
        address expectedAdmin;
        address actualAsset;
        address expectedAsset;
        bytes32 actualMerkleRoot;
        bytes32 expectedMerkleRoot;
        bool actualCancelable;
        bool expectedCancelable;
        uint40 actualExpiration;
        uint40 expectedExpiration;
        address actualLockupLinear;
        address expectedLockupLinear;
        uint40 actualDurationsCliff;
        uint40 actualDurationsTotal;
        LockupLinear.Durations expectedDurations;
        uint256 actualAllowance;
        uint256 expectedAllowance;
    }

    function test_Constructor() external {
        SablierV2AirstreamCampaignLL constructedCampaignLL = new SablierV2AirstreamCampaignLL(
            users.admin.addr,
            asset,
            defaults.merkleRoot(),
            defaults.CANCELABLE(),
            defaults.EXPIRATION(),
            lockupLinear,
            defaults.durations()
        );

        Vars memory vars;

        vars.actualAdmin = constructedCampaignLL.admin();
        vars.expectedAdmin = users.admin.addr;
        assertEq(vars.actualAdmin, vars.expectedAdmin, "admin");

        vars.actualAsset = address(constructedCampaignLL.asset());
        vars.expectedAsset = address(asset);
        assertEq(vars.actualAsset, vars.expectedAsset, "asset");

        vars.actualMerkleRoot = constructedCampaignLL.merkleRoot();
        vars.expectedMerkleRoot = defaults.merkleRoot();
        assertEq(vars.actualMerkleRoot, vars.expectedMerkleRoot, "merkleRoot");

        vars.actualCancelable = constructedCampaignLL.cancelable();
        vars.expectedCancelable = defaults.CANCELABLE();
        assertEq(vars.actualCancelable, vars.expectedCancelable, "cancelable");

        vars.actualExpiration = constructedCampaignLL.expiration();
        vars.expectedExpiration = defaults.EXPIRATION();
        assertEq(vars.actualExpiration, vars.expectedExpiration, "expiration");

        vars.actualLockupLinear = address(constructedCampaignLL.lockupLinear());
        vars.expectedLockupLinear = address(lockupLinear);
        assertEq(vars.actualLockupLinear, vars.expectedLockupLinear, "lockupLinear");

        (vars.actualDurationsCliff, vars.actualDurationsTotal) = constructedCampaignLL.airstreamDurations();
        vars.expectedDurations = defaults.durations();
        assertEq(vars.actualDurationsCliff, vars.expectedDurations.cliff, "cliff");
        assertEq(vars.actualDurationsTotal, vars.expectedDurations.total, "total");

        vars.actualAllowance = asset.allowance(address(constructedCampaignLL), address(lockupLinear));
        vars.expectedAllowance = MAX_UINT256;
        assertEq(vars.actualAllowance, vars.expectedAllowance, "allowance");
    }
}
