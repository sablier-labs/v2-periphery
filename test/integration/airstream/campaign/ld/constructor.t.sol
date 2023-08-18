// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { LockupDynamic } from "@sablier/v2-core/src/types/DataTypes.sol";

import { SablierV2AirstreamCampaignLD } from "src/SablierV2AirstreamCampaignLD.sol";

import { CampaignLD_Integration_Test } from "./campaignLD.t.sol";

contract Constructor_CampaignLD_Integration_Test is CampaignLD_Integration_Test {
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
        address actualLockupDynamic;
        address expectedLockupDynamic;
        LockupDynamic.SegmentWithDelta[] actualSegments;
        LockupDynamic.SegmentWithDelta[] expectedSegments;
        uint256 actualAllowance;
        uint256 expectedAllowance;
    }

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

        Vars memory vars;

        vars.actualAdmin = constructedCampaignLD.admin();
        vars.expectedAdmin = users.admin.addr;
        assertEq(vars.actualAdmin, vars.expectedAdmin, "admin");

        vars.actualAsset = address(constructedCampaignLD.asset());
        vars.expectedAsset = address(asset);
        assertEq(vars.actualAsset, vars.expectedAsset, "asset");

        vars.actualMerkleRoot = constructedCampaignLD.merkleRoot();
        vars.expectedMerkleRoot = defaults.merkleRoot();
        assertEq(vars.actualMerkleRoot, vars.expectedMerkleRoot, "merkleRoot");

        vars.actualCancelable = constructedCampaignLD.cancelable();
        vars.expectedCancelable = defaults.CANCELABLE();
        assertEq(vars.actualCancelable, vars.expectedCancelable, "cancelable");

        vars.actualExpiration = constructedCampaignLD.expiration();
        vars.expectedExpiration = defaults.EXPIRATION();
        assertEq(vars.actualExpiration, vars.expectedExpiration, "expiration");

        vars.actualLockupDynamic = address(constructedCampaignLD.lockupDynamic());
        vars.expectedLockupDynamic = address(lockupDynamic);
        assertEq(vars.actualLockupDynamic, vars.expectedLockupDynamic, "lockupDynamic");

        vars.actualSegments = constructedCampaignLD.getSegments();
        vars.expectedSegments = defaults.segmentsWithDeltas();
        assertEq(vars.actualSegments, vars.expectedSegments, "segments");

        vars.actualAllowance = asset.allowance(address(constructedCampaignLD), address(lockupDynamic));
        vars.expectedAllowance = MAX_UINT256;
        assertEq(vars.actualAllowance, vars.expectedAllowance, "allowance");
    }
}
