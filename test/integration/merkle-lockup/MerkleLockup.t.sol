// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { ISablierV2MerkleLockupLL } from "src/interfaces/ISablierV2MerkleLockupLL.sol";

import { Integration_Test } from "../Integration.t.sol";

abstract contract MerkleLockup_Integration_Test is Integration_Test {
    function setUp() public virtual override {
        Integration_Test.setUp();

        // Create the default Merkle Lockup.
        merkleLockupLL = createMerkleLockupLL();

        // Fund the Merkle Lockup contract.
        deal({ token: address(dai), to: address(merkleLockupLL), give: defaults.AGGREGATE_AMOUNT() });
    }

    function claimLL() internal returns (uint256) {
        return merkleLockupLL.claim({
            index: defaults.INDEX1(),
            recipient: users.recipient1,
            amount: defaults.CLAIM_AMOUNT(),
            merkleProof: defaults.index1Proof()
        });
    }

    function computeMerkleLockupLLAddress() internal returns (address) {
        return computeMerkleLockupLLAddress(users.admin, defaults.MERKLE_ROOT(), defaults.EXPIRATION());
    }

    function computeMerkleLockupLLAddress(address admin) internal returns (address) {
        return computeMerkleLockupLLAddress(admin, defaults.MERKLE_ROOT(), defaults.EXPIRATION());
    }

    function computeMerkleLockupLLAddress(address admin, uint40 expiration) internal returns (address) {
        return computeMerkleLockupLLAddress(admin, defaults.MERKLE_ROOT(), expiration);
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
            baseParams: defaults.baseParams(admin, dai, defaults.MERKLE_ROOT(), expiration),
            lockupLinear: lockupLinear,
            streamDurations: defaults.durations(),
            aggregateAmount: defaults.AGGREGATE_AMOUNT(),
            recipientsCount: defaults.RECIPIENTS_COUNT()
        });
    }
}
