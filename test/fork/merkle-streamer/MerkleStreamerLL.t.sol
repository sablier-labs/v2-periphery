// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Lockup, LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { ISablierV2MerkleStreamerLL } from "src/interfaces/ISablierV2MerkleStreamerLL.sol";

import { MerkleBuilder } from "../../utils/MerkleBuilder.sol";
import { Fork_Test } from "../Fork.t.sol";

abstract contract MerkleStreamerLL_Fork_Test is Fork_Test {
    constructor(IERC20 asset_) Fork_Test(asset_) { }

    function setUp() public virtual override {
        Fork_Test.setUp();
    }

    /// @dev Encapsulates the data needed to compute a Merkle tree leaf.
    struct LeafData {
        uint256 index;
        uint256 recipientSeed;
        uint128 amount;
    }

    struct Params {
        address admin;
        uint40 expiration;
        LeafData[] leafData;
        uint256 leafPos;
    }

    struct Vars {
        uint256 actualStreamId;
        LockupLinear.Stream actualStream;
        uint128[] amounts;
        ISablierV2MerkleStreamerLL merkleStreamerLL;
        uint256 aggregateAmount;
        uint128 clawbackAmount;
        uint256 recipientsCount;
        uint256 expectedStreamId;
        address expectedStreamerLL;
        LockupLinear.Stream expectedStream;
        uint256[] indexes;
        bytes32[] leaves;
        bytes32 merkleRoot;
        address[] recipients;
    }

    function testForkFuzz_MerkleStreamerLL(Params memory params) external {
        vm.assume(params.admin != address(0) && params.admin != users.admin.addr);
        vm.assume(params.expiration == 0 || params.expiration > block.timestamp);
        vm.assume(params.leafData.length > 1);
        params.leafPos = _bound(params.leafPos, 0, params.leafData.length - 1);
        assumeNoBlacklisted({ token: address(asset), addr: params.admin });

        /*//////////////////////////////////////////////////////////////////////////
                                          CREATE
        //////////////////////////////////////////////////////////////////////////*/

        Vars memory vars;
        vars.recipientsCount = params.leafData.length;
        vars.amounts = new uint128[](vars.recipientsCount);
        vars.indexes = new uint256[](vars.recipientsCount);
        vars.recipients = new address[](vars.recipientsCount);
        for (uint256 i = 0; i < vars.recipientsCount; ++i) {
            vars.indexes[i] = params.leafData[i].index;

            // Bound each leaf amount so that `aggregateAmount` does not overflow.
            vars.amounts[i] = uint128(_bound(params.leafData[i].amount, 1, MAX_UINT256 / vars.recipientsCount - 1));
            vars.aggregateAmount += params.leafData[i].amount;

            // Avoid zero recipient addresses.
            uint256 boundedRecipientSeed = _bound(params.leafData[i].recipientSeed, 1, MAX_UINT256);
            vars.recipients[i] = address(uint160(boundedRecipientSeed));
        }

        vars.leaves = MerkleBuilder.computeLeaves(vars.indexes, vars.recipients, vars.amounts);
        vars.merkleRoot = getRoot(vars.leaves);

        vars.expectedStreamerLL = computeMerkleStreamerLLAddress(params.admin, vars.merkleRoot, params.expiration);
        vm.expectEmit({ emitter: address(merkleStreamerFactory) });
        emit CreateMerkleStreamerLL({
            merkleStreamer: ISablierV2MerkleStreamerLL(vars.expectedStreamerLL),
            admin: params.admin,
            lockupLinear: lockupLinear,
            asset: asset,
            expiration: params.expiration,
            streamDurations: defaults.durations(),
            cancelable: defaults.CANCELABLE(),
            ipfsCID: defaults.IPFS_CID(),
            aggregateAmount: vars.aggregateAmount,
            recipientsCount: vars.recipientsCount
        });

        vars.merkleStreamerLL = merkleStreamerFactory.createMerkleStreamerLL({
            initialAdmin: params.admin,
            lockupLinear: lockupLinear,
            asset: asset,
            merkleRoot: vars.merkleRoot,
            expiration: params.expiration,
            streamDurations: defaults.durations(),
            cancelable: defaults.CANCELABLE(),
            ipfsCID: defaults.IPFS_CID(),
            aggregateAmount: vars.aggregateAmount,
            recipientsCount: vars.recipientsCount
        });

        // Fund the Merkle streamer.
        deal({ token: address(asset), to: address(vars.merkleStreamerLL), give: vars.aggregateAmount });

        assertGt(address(vars.merkleStreamerLL).code.length, 0, "MerkleStreamerLL contract not created");
        assertEq(
            address(vars.merkleStreamerLL),
            vars.expectedStreamerLL,
            "MerkleStreamerLL contract does not match computed address"
        );

        /*//////////////////////////////////////////////////////////////////////////
                                          CLAIM
        //////////////////////////////////////////////////////////////////////////*/

        assertFalse(vars.merkleStreamerLL.hasClaimed(vars.indexes[params.leafPos]));

        vars.expectedStreamId = lockupLinear.nextStreamId();
        emit Claim(
            vars.indexes[params.leafPos],
            vars.recipients[params.leafPos],
            vars.amounts[params.leafPos],
            vars.expectedStreamId
        );
        vars.actualStreamId = vars.merkleStreamerLL.claim({
            index: vars.indexes[params.leafPos],
            recipient: vars.recipients[params.leafPos],
            amount: vars.amounts[params.leafPos],
            merkleProof: getProof(vars.leaves, params.leafPos)
        });

        vars.actualStream = lockupLinear.getStream(vars.actualStreamId);
        vars.expectedStream = LockupLinear.Stream({
            amounts: Lockup.Amounts({ deposited: vars.amounts[params.leafPos], refunded: 0, withdrawn: 0 }),
            asset: asset,
            cliffTime: uint40(block.timestamp) + defaults.CLIFF_DURATION(),
            endTime: uint40(block.timestamp) + defaults.TOTAL_DURATION(),
            isCancelable: defaults.CANCELABLE(),
            isDepleted: false,
            isStream: true,
            sender: params.admin,
            startTime: uint40(block.timestamp),
            wasCanceled: false
        });

        assertTrue(vars.merkleStreamerLL.hasClaimed(vars.indexes[params.leafPos]));
        assertEq(vars.actualStreamId, vars.expectedStreamId);
        assertEq(vars.actualStream, vars.expectedStream);

        /*//////////////////////////////////////////////////////////////////////////
                                        CLAWBACK
        //////////////////////////////////////////////////////////////////////////*/

        if (params.expiration > 0) {
            vars.clawbackAmount = uint128(asset.balanceOf(address(vars.merkleStreamerLL)));
            vm.warp({ timestamp: uint256(params.expiration) + 1 seconds });

            changePrank({ msgSender: params.admin });
            expectCallToTransfer({ to: params.admin, amount: vars.clawbackAmount });
            vm.expectEmit({ emitter: address(vars.merkleStreamerLL) });
            emit Clawback({ to: params.admin, admin: params.admin, amount: vars.clawbackAmount });
            vars.merkleStreamerLL.clawback({ to: params.admin, amount: vars.clawbackAmount });
        }
    }
}
