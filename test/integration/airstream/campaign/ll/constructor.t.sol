// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { SablierV2AirstreamCampaignLL } from "src/SablierV2AirstreamCampaignLL.sol";

import { CampaignLL_Integration_Test } from "./campaignLL.t.sol";

contract Constructor_CampaignLL_Integration_Test is CampaignLL_Integration_Test {
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

        address actualAdmin = constructedCampaignLL.admin();
        address expectedAdmin = users.admin.addr;
        assertEq(actualAdmin, expectedAdmin, "admin");

        address actualAsset = address(constructedCampaignLL.asset());
        address expectedAsset = address(asset);
        assertEq(actualAsset, expectedAsset, "asset");

        bytes32 actualMerkleRoot = constructedCampaignLL.merkleRoot();
        bytes32 expectedMerkleRoot = defaults.merkleRoot();
        assertEq(actualMerkleRoot, expectedMerkleRoot, "merkleRoot");

        bool actualCancelable = constructedCampaignLL.cancelable();
        bool expectedCancelable = defaults.CANCELABLE();
        assertEq(actualCancelable, expectedCancelable, "cancelable");

        uint40 actualExpiration = constructedCampaignLL.expiration();
        uint40 expectedExpiration = defaults.EXPIRATION();
        assertEq(actualExpiration, expectedExpiration, "expiration");

        address actualLockupLinear = address(constructedCampaignLL.lockupLinear());
        address expectedLockupLinear = address(lockupLinear);
        assertEq(actualLockupLinear, expectedLockupLinear, "lockupLinear");

        (uint40 actualDurationsCliff, uint40 actualDurationsTotal) = constructedCampaignLL.durations();
        LockupLinear.Durations memory expectedDurations = defaults.durations();
        assertEq(actualDurationsCliff, expectedDurations.cliff, "cliff");
        assertEq(actualDurationsTotal, expectedDurations.total, "total");
    }
}
