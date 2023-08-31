// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { SablierV2AirstreamCampaignLL } from "src/SablierV2AirstreamCampaignLL.sol";

import { Airstream_Integration_Test } from "../../Airstream.t.sol";

contract Constructor_CampaignLL_Integration_Test is Airstream_Integration_Test {
    /// @dev Needed to prevent "Stack too deep" error
    struct Vars {
        address actualAdmin;
        uint256 actualAllowance;
        address actualAsset;
        bool actualCancelable;
        LockupLinear.Durations actualDurations;
        uint40 actualExpiration;
        address actualLockupLinear;
        bytes32 actualMerkleRoot;
        address expectedAdmin;
        uint256 expectedAllowance;
        address expectedAsset;
        bool expectedCancelable;
        LockupLinear.Durations expectedDurations;
        uint40 expectedExpiration;
        address expectedLockupLinear;
        bytes32 expectedMerkleRoot;
    }

    function test_Constructor() external {
        SablierV2AirstreamCampaignLL constructedCampaignLL = new SablierV2AirstreamCampaignLL(
            users.admin.addr,
            lockupLinear,
            asset,
            defaults.merkleRoot(),
            defaults.EXPIRATION(),
            defaults.durations(),
            defaults.CANCELABLE()
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

        (vars.actualDurations.cliff, vars.actualDurations.total) = constructedCampaignLL.airstreamDurations();
        vars.expectedDurations = defaults.durations();
        assertEq(vars.actualDurations.cliff, vars.expectedDurations.cliff, "durations.cliff");
        assertEq(vars.actualDurations.total, vars.expectedDurations.total, "durations.total");

        vars.actualAllowance = asset.allowance(address(constructedCampaignLL), address(lockupLinear));
        vars.expectedAllowance = MAX_UINT256;
        assertEq(vars.actualAllowance, vars.expectedAllowance, "allowance");
    }
}
