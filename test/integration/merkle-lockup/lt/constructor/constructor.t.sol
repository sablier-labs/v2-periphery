// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { LockupTranched } from "@sablier/v2-core/src/types/DataTypes.sol";

import { SablierV2MerkleLockupLT } from "src/SablierV2MerkleLockupLT.sol";
import { MerkleLockupLT } from "src/types/DataTypes.sol";

import { MerkleLockup_Integration_Test } from "../../MerkleLockup.t.sol";

contract Constructor_MerkleLockupLT_Integration_Test is MerkleLockup_Integration_Test {
    /// @dev Needed to prevent "Stack too deep" error
    struct Vars {
        address actualAdmin;
        uint256 actualAllowance;
        address actualAsset;
        string actualIpfsCID;
        string actualName;
        bool actualCancelable;
        bool actualTransferable;
        MerkleLockupLT.TrancheWithPercentage[] actualTranchesWithPercentages;
        uint40 actualExpiration;
        address actualLockupTranched;
        bytes32 actualMerkleRoot;
        address expectedAdmin;
        uint256 expectedAllowance;
        address expectedAsset;
        string expectedIpfsCID;
        bytes32 expectedName;
        bool expectedCancelable;
        bool expectedTransferable;
        MerkleLockupLT.TrancheWithPercentage[] expectedTranchesWithPercentages;
        uint40 expectedExpiration;
        address expectedLockupTranched;
        bytes32 expectedMerkleRoot;
    }

    function test_Constructor() external {
        SablierV2MerkleLockupLT constructedLockupLT =
            new SablierV2MerkleLockupLT(defaults.baseParams(), lockupTranched, defaults.tranchesWithPercentages());

        Vars memory vars;

        vars.actualAdmin = constructedLockupLT.admin();
        vars.expectedAdmin = users.admin;
        assertEq(vars.actualAdmin, vars.expectedAdmin, "admin");

        vars.actualAsset = address(constructedLockupLT.ASSET());
        vars.expectedAsset = address(dai);
        assertEq(vars.actualAsset, vars.expectedAsset, "asset");

        vars.actualName = constructedLockupLT.name();
        vars.expectedName = defaults.NAME_BYTES32();
        assertEq(bytes32(abi.encodePacked(vars.actualName)), vars.expectedName, "name");

        vars.actualMerkleRoot = constructedLockupLT.MERKLE_ROOT();
        vars.expectedMerkleRoot = defaults.MERKLE_ROOT();
        assertEq(vars.actualMerkleRoot, vars.expectedMerkleRoot, "merkleRoot");

        vars.actualCancelable = constructedLockupLT.CANCELABLE();
        vars.expectedCancelable = defaults.CANCELABLE();
        assertEq(vars.actualCancelable, vars.expectedCancelable, "cancelable");

        vars.actualTransferable = constructedLockupLT.TRANSFERABLE();
        vars.expectedTransferable = defaults.TRANSFERABLE();
        assertEq(vars.actualTransferable, vars.expectedTransferable, "transferable");

        vars.actualExpiration = constructedLockupLT.EXPIRATION();
        vars.expectedExpiration = defaults.EXPIRATION();
        assertEq(vars.actualExpiration, vars.expectedExpiration, "expiration");

        vars.actualLockupTranched = address(constructedLockupLT.LOCKUP_TRANCHED());
        vars.expectedLockupTranched = address(lockupTranched);
        assertEq(vars.actualLockupTranched, vars.expectedLockupTranched, "LockupTranched");

        vars.actualTranchesWithPercentages = constructedLockupLT.getTranchesWithPercentage();
        vars.expectedTranchesWithPercentages = defaults.tranchesWithPercentages();
        assertEq(vars.actualTranchesWithPercentages, vars.expectedTranchesWithPercentages);

        vars.actualAllowance = dai.allowance(address(constructedLockupLT), address(lockupTranched));
        vars.expectedAllowance = MAX_UINT256;
        assertEq(vars.actualAllowance, vars.expectedAllowance, "allowance");

        vars.actualIpfsCID = constructedLockupLT.ipfsCID();
        vars.expectedIpfsCID = defaults.IPFS_CID();
        assertEq(vars.actualIpfsCID, vars.expectedIpfsCID, "ipfsCID");
    }
}
