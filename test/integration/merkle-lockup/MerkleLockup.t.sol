// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { ISablierV2MerkleLockupLL } from "src/interfaces/ISablierV2MerkleLockupLL.sol";
import { ISablierV2MerkleLockupLT } from "src/interfaces/ISablierV2MerkleLockupLT.sol";

import { Integration_Test } from "../Integration.t.sol";

abstract contract MerkleLockup_Integration_Test is Integration_Test {
    function setUp() public virtual override {
        Integration_Test.setUp();

        // Create the default Merkle Lockup contracts.
        merkleLockupLL = createMerkleLockupLL();
        merkleLockupLT = createMerkleLockupLT();

        // Fund the Merkle Lockup contracts.
        deal({ token: address(dai), to: address(merkleLockupLL), give: defaults.AGGREGATE_AMOUNT() });
        deal({ token: address(dai), to: address(merkleLockupLT), give: defaults.AGGREGATE_AMOUNT() });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  MERKLE-LOCKUP-LL
    //////////////////////////////////////////////////////////////////////////*/

    function claimLL() internal returns (uint256) {
        return merkleLockupLL.claim({
            index: defaults.INDEX1(),
            recipient: users.recipient1,
            amount: defaults.CLAIM_AMOUNT(),
            merkleProof: defaults.index1Proof()
        });
    }

    function computeMerkleLockupLLAddress() internal view returns (address) {
        return computeMerkleLockupLLAddress(users.admin, defaults.MERKLE_ROOT(), defaults.EXPIRATION());
    }

    function computeMerkleLockupLLAddress(address admin) internal view returns (address) {
        return computeMerkleLockupLLAddress(admin, defaults.MERKLE_ROOT(), defaults.EXPIRATION());
    }

    function computeMerkleLockupLLAddress(address admin, uint40 expiration) internal view returns (address) {
        return computeMerkleLockupLLAddress(admin, defaults.MERKLE_ROOT(), expiration);
    }

    function computeMerkleLockupLLAddress(address admin, bytes32 merkleRoot) internal view returns (address) {
        return computeMerkleLockupLLAddress(admin, merkleRoot, defaults.EXPIRATION());
    }

    function createMerkleLockupLL() internal returns (ISablierV2MerkleLockupLL) {
        return createMerkleLockupLL(users.admin, defaults.EXPIRATION());
    }

    function createMerkleLockupLL(address admin) internal returns (ISablierV2MerkleLockupLL) {
        return createMerkleLockupLL(admin, defaults.EXPIRATION());
    }

    function createMerkleLockupLL(uint40 expiration) internal returns (ISablierV2MerkleLockupLL) {
        return createMerkleLockupLL(users.admin, expiration);
    }

    function createMerkleLockupLL(address admin, uint40 expiration) internal returns (ISablierV2MerkleLockupLL) {
        return merkleLockupFactory.createMerkleLockupLL({
            baseParams: defaults.baseParams(admin, dai, defaults.MERKLE_ROOT(), expiration),
            lockupLinear: lockupLinear,
            streamDurations: defaults.durations(),
            aggregateAmount: defaults.AGGREGATE_AMOUNT(),
            recipientsCount: defaults.RECIPIENTS_COUNT()
        });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  MERKLE-LOCKUP-LT
    //////////////////////////////////////////////////////////////////////////*/

    function claimLT() internal returns (uint256) {
        return merkleLockupLT.claim({
            index: defaults.INDEX1(),
            recipient: users.recipient1,
            amount: defaults.CLAIM_AMOUNT(),
            merkleProof: defaults.index1Proof()
        });
    }

    function computeMerkleLockupLTAddress() internal view returns (address) {
        return computeMerkleLockupLTAddress(users.admin, defaults.MERKLE_ROOT(), defaults.EXPIRATION());
    }

    function computeMerkleLockupLTAddress(address admin) internal view returns (address) {
        return computeMerkleLockupLTAddress(admin, defaults.MERKLE_ROOT(), defaults.EXPIRATION());
    }

    function computeMerkleLockupLTAddress(address admin, uint40 expiration) internal view returns (address) {
        return computeMerkleLockupLTAddress(admin, defaults.MERKLE_ROOT(), expiration);
    }

    function computeMerkleLockupLTAddress(address admin, bytes32 merkleRoot) internal view returns (address) {
        return computeMerkleLockupLTAddress(admin, merkleRoot, defaults.EXPIRATION());
    }

    function createMerkleLockupLT() internal returns (ISablierV2MerkleLockupLT) {
        return createMerkleLockupLT(users.admin, defaults.EXPIRATION());
    }

    function createMerkleLockupLT(address admin) internal returns (ISablierV2MerkleLockupLT) {
        return createMerkleLockupLT(admin, defaults.EXPIRATION());
    }

    function createMerkleLockupLT(uint40 expiration) internal returns (ISablierV2MerkleLockupLT) {
        return createMerkleLockupLT(users.admin, expiration);
    }

    function createMerkleLockupLT(address admin, uint40 expiration) internal returns (ISablierV2MerkleLockupLT) {
        return merkleLockupFactory.createMerkleLockupLT({
            baseParams: defaults.baseParams(admin, dai, defaults.MERKLE_ROOT(), expiration),
            lockupTranched: lockupTranched,
            tranchesWithPercentages: defaults.tranchesWithPercentages(),
            aggregateAmount: defaults.AGGREGATE_AMOUNT(),
            recipientsCount: defaults.RECIPIENTS_COUNT()
        });
    }
}
