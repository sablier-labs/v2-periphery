// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { LockupDynamic } from "@sablier/v2-core/src/types/DataTypes.sol";

import { SablierV2MerkleLockupLD } from "src/SablierV2MerkleLockupLD.sol";

import { MerkleLockup_Integration_Test } from "../../MerkleLockup.t.sol";

contract Constructor_MerkleLockupLD_Integration_Test is MerkleLockup_Integration_Test {
    /// @dev Needed to prevent "Stack too deep" error
    struct Vars {
        address actualAdmin;
        uint256 actualAllowance;
        address actualAsset;
        string actualName;
        bool actualCancelable;
        bool actualTransferable;
        uint40 actualExpiration;
        address actualLockupDynamic;
        bytes32 actualMerkleRoot;
        address expectedAdmin;
        uint256 expectedAllowance;
        address expectedAsset;
        bytes32 expectedName;
        bool expectedCancelable;
        bool expectedTransferable;
        uint40 expectedExpiration;
        address expectedLockupDynamic;
        bytes32 expectedMerkleRoot;
    }

    function test_Constructor() external {
        SablierV2MerkleLockupLD constructedLockupLD =
            new SablierV2MerkleLockupLD(defaults.baseParamsLD(), lockupDynamic);

        Vars memory vars;

        vars.actualAdmin = constructedLockupLD.admin();
        vars.expectedAdmin = users.admin;
        assertEq(vars.actualAdmin, vars.expectedAdmin, "admin");

        vars.actualAsset = address(constructedLockupLD.ASSET());
        vars.expectedAsset = address(dai);
        assertEq(vars.actualAsset, vars.expectedAsset, "asset");

        vars.actualName = constructedLockupLD.name();
        vars.expectedName = defaults.NAME_BYTES32();
        assertEq(bytes32(abi.encodePacked(vars.actualName)), vars.expectedName, "name");

        vars.actualMerkleRoot = constructedLockupLD.MERKLE_ROOT();
        vars.expectedMerkleRoot = defaults.MERKLE_ROOT_LD();
        assertEq(vars.actualMerkleRoot, vars.expectedMerkleRoot, "merkleRoot");

        vars.actualCancelable = constructedLockupLD.CANCELABLE();
        vars.expectedCancelable = defaults.CANCELABLE();
        assertEq(vars.actualCancelable, vars.expectedCancelable, "cancelable");

        vars.actualTransferable = constructedLockupLD.TRANSFERABLE();
        vars.expectedTransferable = defaults.TRANSFERABLE();
        assertEq(vars.actualTransferable, vars.expectedTransferable, "transferable");

        vars.actualExpiration = constructedLockupLD.EXPIRATION();
        vars.expectedExpiration = defaults.EXPIRATION();
        assertEq(vars.actualExpiration, vars.expectedExpiration, "expiration");

        vars.actualLockupDynamic = address(constructedLockupLD.LOCKUP_DYNAMIC());
        vars.expectedLockupDynamic = address(lockupDynamic);
        assertEq(vars.actualLockupDynamic, vars.expectedLockupDynamic, "lockupDynamic");

        vars.actualAllowance = dai.allowance(address(constructedLockupLD), address(lockupDynamic));
        vars.expectedAllowance = MAX_UINT256;
        assertEq(vars.actualAllowance, vars.expectedAllowance, "allowance");
    }
}
