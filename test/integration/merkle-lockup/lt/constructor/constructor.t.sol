// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

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
        uint40 actualExpiration;
        address actualLockupTranched;
        bytes32 actualMerkleRoot;
        MerkleLockupLT.TrancheWithPercentage[] actualTranchesWithPercentages;
        bool actualTransferable;
        address expectedAdmin;
        uint256 expectedAllowance;
        address expectedAsset;
        bool expectedCancelable;
        string expectedIpfsCID;
        uint40 expectedExpiration;
        address expectedLockupTranched;
        bytes32 expectedMerkleRoot;
        bytes32 expectedName;
        MerkleLockupLT.TrancheWithPercentage[] expectedTranchesWithPercentages;
        bool expectedTransferable;
    }

    function test_Constructor() external {
        SablierV2MerkleLockupLT constructedLockupLT =
            new SablierV2MerkleLockupLT(defaults.baseParams(), lockupTranched, defaults.tranchesWithPercentages());

        Vars memory vars;

        vars.actualAdmin = constructedLockupLT.admin();
        vars.expectedAdmin = users.admin;
        assertEq(vars.actualAdmin, vars.expectedAdmin, "admin");

        vars.actualAllowance = dai.allowance(address(constructedLockupLT), address(lockupTranched));
        vars.expectedAllowance = MAX_UINT256;
        assertEq(vars.actualAllowance, vars.expectedAllowance, "allowance");

        vars.actualAsset = address(constructedLockupLT.ASSET());
        vars.expectedAsset = address(dai);
        assertEq(vars.actualAsset, vars.expectedAsset, "asset");

        vars.actualCancelable = constructedLockupLT.CANCELABLE();
        vars.expectedCancelable = defaults.CANCELABLE();
        assertEq(vars.actualCancelable, vars.expectedCancelable, "cancelable");

        vars.actualExpiration = constructedLockupLT.EXPIRATION();
        vars.expectedExpiration = defaults.EXPIRATION();
        assertEq(vars.actualExpiration, vars.expectedExpiration, "expiration");

        vars.actualIpfsCID = constructedLockupLT.ipfsCID();
        vars.expectedIpfsCID = defaults.IPFS_CID();
        assertEq(vars.actualIpfsCID, vars.expectedIpfsCID, "ipfsCID");

        vars.actualLockupTranched = address(constructedLockupLT.LOCKUP_TRANCHED());
        vars.expectedLockupTranched = address(lockupTranched);
        assertEq(vars.actualLockupTranched, vars.expectedLockupTranched, "lockupTranched");

        vars.actualName = constructedLockupLT.name();
        vars.expectedName = defaults.NAME_BYTES32();
        assertEq(bytes32(abi.encodePacked(vars.actualName)), vars.expectedName, "name");

        vars.actualMerkleRoot = constructedLockupLT.MERKLE_ROOT();
        vars.expectedMerkleRoot = defaults.MERKLE_ROOT();
        assertEq(vars.actualMerkleRoot, vars.expectedMerkleRoot, "merkleRoot");

        vars.actualTranchesWithPercentages = constructedLockupLT.getTranchesWithPercentages();
        vars.expectedTranchesWithPercentages = defaults.tranchesWithPercentages();
        assertEq(vars.actualTranchesWithPercentages, vars.expectedTranchesWithPercentages, "tranchesWithPercentages");

        vars.actualTransferable = constructedLockupLT.TRANSFERABLE();
        vars.expectedTransferable = defaults.TRANSFERABLE();
        assertEq(vars.actualTransferable, vars.expectedTransferable, "transferable");
    }
}
