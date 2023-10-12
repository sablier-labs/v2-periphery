// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { ISablierV2MerkleStreamerLL } from "src/interfaces/ISablierV2MerkleStreamerLL.sol";

import { Integration_Test } from "../Integration.t.sol";

abstract contract MerkleStreamer_Integration_Test is Integration_Test {
    function setUp() public virtual override {
        Integration_Test.setUp();

        // Create the default Merkle streamer.
        merkleStreamerLL = createMerkleStreamerLL();

        // Fund the Merkle streamer.
        deal({ token: address(asset), to: address(merkleStreamerLL), give: defaults.AGGREGATE_AMOUNT() });
    }

    function claimLL() internal returns (uint256) {
        return merkleStreamerLL.claim({
            index: defaults.INDEX1(),
            recipient: users.recipient1.addr,
            amount: defaults.CLAIM_AMOUNT(),
            merkleProof: defaults.index1Proof()
        });
    }

    function createMerkleStreamerLL() internal returns (ISablierV2MerkleStreamerLL) {
        return createMerkleStreamerLL(users.admin.addr, defaults.EXPIRATION());
    }

    function createMerkleStreamerLL(address admin) internal returns (ISablierV2MerkleStreamerLL) {
        return createMerkleStreamerLL(admin, defaults.EXPIRATION());
    }

    function createMerkleStreamerLL(uint40 expiration) internal returns (ISablierV2MerkleStreamerLL) {
        return createMerkleStreamerLL(users.admin.addr, expiration);
    }

    function createMerkleStreamerLL(address admin, uint40 expiration) internal returns (ISablierV2MerkleStreamerLL) {
        return merkleStreamerFactory.createMerkleStreamerLL({
            initialAdmin: admin,
            lockupLinear: lockupLinear,
            asset: asset,
            merkleRoot: defaults.MERKLE_ROOT(),
            expiration: expiration,
            cancelable: defaults.CANCELABLE(),
            transferable: defaults.TRANSFERABLE(),
            streamDurations: defaults.durations(),
            ipfsCID: defaults.IPFS_CID(),
            aggregateAmount: defaults.AGGREGATE_AMOUNT(),
            recipientsCount: defaults.RECIPIENTS_COUNT()
        });
    }
}
