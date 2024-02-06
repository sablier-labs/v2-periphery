// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { ISablierV2MerkleLockupLD } from "src/interfaces/ISablierV2MerkleLockupLD.sol";
import { ISablierV2MerkleLockupLL } from "src/interfaces/ISablierV2MerkleLockupLL.sol";

import { Integration_Test } from "../Integration.t.sol";

abstract contract MerkleLockup_Integration_Test is Integration_Test {
    function setUp() public virtual override {
        Integration_Test.setUp();

        // Create the default Merkle Lockup contracts.
        merkleLockupLL = createMerkleLockupLL();
        merkleLockupLD = createMerkleLockupLD();

        // Fund the Merkle Lockup contract.
        deal({ token: address(dai), to: address(merkleLockupLL), give: defaults.AGGREGATE_AMOUNT() });
        deal({ token: address(dai), to: address(merkleLockupLD), give: defaults.AGGREGATE_AMOUNT() });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  MERKLE-LOCKUP-LD
    //////////////////////////////////////////////////////////////////////////*/

    function claimLD() internal returns (uint256) {
        return merkleLockupLD.claim({
            index: defaults.INDEX1(),
            recipient: users.recipient1,
            amount: defaults.CLAIM_AMOUNT(),
            segments: defaults.segmentsWithDurations(),
            merkleProof: defaults.index1ProofLD()
        });
    }

    function computeMerkleLockupLDAddress() internal returns (address) {
        return computeMerkleLockupLDAddress(users.admin, defaults.MERKLE_ROOT_LD(), defaults.EXPIRATION());
    }

    function computeMerkleLockupLDAddress(address admin) internal returns (address) {
        return computeMerkleLockupLDAddress(admin, defaults.MERKLE_ROOT_LD(), defaults.EXPIRATION());
    }

    function computeMerkleLockupLDAddress(address admin, uint40 expiration) internal returns (address) {
        return computeMerkleLockupLDAddress(admin, defaults.MERKLE_ROOT_LD(), expiration);
    }

    function computeMerkleLockupLDAddress(address admin, bytes32 merkleRoot) internal returns (address) {
        return computeMerkleLockupLDAddress(admin, merkleRoot, defaults.EXPIRATION());
    }

    function createMerkleLockupLD() internal returns (ISablierV2MerkleLockupLD) {
        return createMerkleLockupLD(users.admin, defaults.EXPIRATION());
    }

    function createMerkleLockupLD(address admin) internal returns (ISablierV2MerkleLockupLD) {
        return createMerkleLockupLD(admin, defaults.EXPIRATION());
    }

    function createMerkleLockupLD(uint40 expiration) internal returns (ISablierV2MerkleLockupLD) {
        return createMerkleLockupLD(users.admin, expiration);
    }

    function createMerkleLockupLD(address admin, uint40 expiration) internal returns (ISablierV2MerkleLockupLD) {
        return merkleLockupFactory.createMerkleLockupLD({
            baseParams: defaults.baseParams(admin, defaults.MERKLE_ROOT_LD(), expiration),
            lockupDynamic: lockupDynamic,
            ipfsCID: defaults.IPFS_CID(),
            aggregateAmount: defaults.AGGREGATE_AMOUNT(),
            recipientsCount: defaults.RECIPIENTS_COUNT()
        });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  MERKLE-LOCKUP-LL
    //////////////////////////////////////////////////////////////////////////*/

    function claimLL() internal returns (uint256) {
        return merkleLockupLL.claim({
            index: defaults.INDEX1(),
            recipient: users.recipient1,
            amount: defaults.CLAIM_AMOUNT(),
            merkleProof: defaults.index1ProofLL()
        });
    }

    function computeMerkleLockupLLAddress() internal returns (address) {
        return computeMerkleLockupLLAddress(users.admin, defaults.MERKLE_ROOT_LL(), defaults.EXPIRATION());
    }

    function computeMerkleLockupLLAddress(address admin) internal returns (address) {
        return computeMerkleLockupLLAddress(admin, defaults.MERKLE_ROOT_LL(), defaults.EXPIRATION());
    }

    function computeMerkleLockupLLAddress(address admin, uint40 expiration) internal returns (address) {
        return computeMerkleLockupLLAddress(admin, defaults.MERKLE_ROOT_LL(), expiration);
    }

    function computeMerkleLockupLLAddress(address admin, bytes32 merkleRoot) internal returns (address) {
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
            baseParams: defaults.baseParams(admin, dai, defaults.MERKLE_ROOT_LL(), expiration),
            lockupLinear: lockupLinear,
            streamDurations: defaults.durations(),
            ipfsCID: defaults.IPFS_CID(),
            aggregateAmount: defaults.AGGREGATE_AMOUNT(),
            recipientsCount: defaults.RECIPIENTS_COUNT()
        });
    }
}
