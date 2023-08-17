// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { LockupDynamic } from "@sablier/v2-core/src/types/DataTypes.sol";

import { SablierV2AirstreamCampaignLD } from "src/SablierV2AirstreamCampaignLD.sol";

import { CampaignLD_Integration_Test } from "./campaignLD.t.sol";

contract Constructor_CampaignLD_Integration_Test is CampaignLD_Integration_Test {
    function test_Constructor() external {
        SablierV2AirstreamCampaignLD constructedCampaignLD = new SablierV2AirstreamCampaignLD(
            users.admin.addr,
            asset,
            defaults.merkleRoot(),
            defaults.CANCELABLE(),
            defaults.EXPIRATION(),
            lockupDynamic,
            defaults.segmentsWithDeltas()
        );

        address actualAdmin = constructedCampaignLD.admin();
        address expectedAdmin = users.admin.addr;
        assertEq(actualAdmin, expectedAdmin, "admin");

        address actualAsset = address(constructedCampaignLD.asset());
        address expectedAsset = address(asset);
        assertEq(actualAsset, expectedAsset, "asset");

        bytes32 actualMerkleRoot = constructedCampaignLD.merkleRoot();
        bytes32 expectedMerkleRoot = defaults.merkleRoot();
        assertEq(actualMerkleRoot, expectedMerkleRoot, "merkleRoot");

        bool actualCancelable = constructedCampaignLD.cancelable();
        bool expectedCancelable = defaults.CANCELABLE();
        assertEq(actualCancelable, expectedCancelable, "cancelable");

        uint40 actualExpiration = constructedCampaignLD.expiration();
        uint40 expectedExpiration = defaults.EXPIRATION();
        assertEq(actualExpiration, expectedExpiration, "expiration");

        address actualLockupDynamic = address(constructedCampaignLD.lockupDynamic());
        address expectedLockupDynamic = address(lockupDynamic);
        assertEq(actualLockupDynamic, expectedLockupDynamic, "lockupDynamic");

        LockupDynamic.SegmentWithDelta[] memory actualSegments = constructedCampaignLD.getSegments();
        LockupDynamic.SegmentWithDelta[] memory expectedSegments = defaults.segmentsWithDeltas();
        assertEq(actualSegments, expectedSegments, "segments");
    }
}
