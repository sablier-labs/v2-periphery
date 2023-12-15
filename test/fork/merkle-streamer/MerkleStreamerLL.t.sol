// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Arrays } from "@openzeppelin/contracts/utils/Arrays.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Lockup, LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { ISablierV2MerkleStreamerLL } from "src/interfaces/ISablierV2MerkleStreamerLL.sol";

import { MerkleBuilder } from "../../utils/MerkleBuilder.sol";
import { Fork_Test } from "../Fork.t.sol";

abstract contract MerkleStreamerLL_Fork_Test is Fork_Test {
    using MerkleBuilder for uint256[];

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
        uint256 posBeforeSort;
    }

    struct Vars {
        uint256 actualStreamId;
        LockupLinear.Stream actualStream;
        uint128[] amounts;
        uint256 aggregateAmount;
        uint128 clawbackAmount;
        address expectedStreamerLL;
        LockupLinear.Stream expectedStream;
        uint256 expectedStreamId;
        uint256[] indexes;
        uint256 leafPos;
        uint256 leafToClaim;
        ISablierV2MerkleStreamerLL merkleStreamerLL;
        bytes32 merkleRoot;
        address[] recipients;
        uint256 recipientsCount;
    }

    // We need the leaves as a storage variable so that we can use OpenZeppelin's {Arrays.findUpperBound}.
    uint256[] public leaves;

    function testForkFuzz_MerkleStreamerLL(Params memory params) external {
        vm.assume(params.admin != address(0) && params.admin != users.admin);
        vm.assume(params.expiration == 0 || params.expiration > block.timestamp);
        vm.assume(params.leafData.length > 1);
        params.posBeforeSort = _bound(params.posBeforeSort, 0, params.leafData.length - 1);
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
            uint256 boundedRecipientSeed = _bound(params.leafData[i].recipientSeed, 1, type(uint160).max);
            vars.recipients[i] = address(uint160(boundedRecipientSeed));
        }

        leaves = new uint256[](vars.recipientsCount);
        leaves = MerkleBuilder.computeLeaves(vars.indexes, vars.recipients, vars.amounts);

        // Sort the leaves in ascending order to match the production environment.
        MerkleBuilder.sortLeaves(leaves);
        vars.merkleRoot = getRoot(leaves.toBytes32());

        vars.expectedStreamerLL = computeMerkleStreamerLLAddress(params.admin, vars.merkleRoot, params.expiration);
        vm.expectEmit({ emitter: address(merkleStreamerFactory) });
        emit CreateMerkleStreamerLL({
            merkleStreamer: ISablierV2MerkleStreamerLL(vars.expectedStreamerLL),
            admin: params.admin,
            lockupLinear: lockupLinear,
            asset: asset,
            merkleRoot: vars.merkleRoot,
            expiration: params.expiration,
            streamDurations: defaults.durations(),
            cancelable: defaults.CANCELABLE(),
            transferable: defaults.TRANSFERABLE(),
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
            transferable: defaults.TRANSFERABLE(),
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

        assertFalse(vars.merkleStreamerLL.hasClaimed(vars.indexes[params.posBeforeSort]));

        vars.leafToClaim = MerkleBuilder.computeLeaf(
            vars.indexes[params.posBeforeSort],
            vars.recipients[params.posBeforeSort],
            vars.amounts[params.posBeforeSort]
        );
        vars.leafPos = Arrays.findUpperBound(leaves, vars.leafToClaim);

        vars.expectedStreamId = lockupLinear.nextStreamId();
        emit Claim(
            vars.indexes[params.posBeforeSort],
            vars.recipients[params.posBeforeSort],
            vars.amounts[params.posBeforeSort],
            vars.expectedStreamId
        );
        vars.actualStreamId = vars.merkleStreamerLL.claim({
            index: vars.indexes[params.posBeforeSort],
            recipient: vars.recipients[params.posBeforeSort],
            amount: vars.amounts[params.posBeforeSort],
            merkleProof: getProof(leaves.toBytes32(), vars.leafPos)
        });

        vars.actualStream = lockupLinear.getStream(vars.actualStreamId);
        vars.expectedStream = LockupLinear.Stream({
            amounts: Lockup.Amounts({ deposited: vars.amounts[params.posBeforeSort], refunded: 0, withdrawn: 0 }),
            asset: asset,
            cliffTime: uint40(block.timestamp) + defaults.CLIFF_DURATION(),
            endTime: uint40(block.timestamp) + defaults.TOTAL_DURATION(),
            isCancelable: defaults.CANCELABLE(),
            isDepleted: false,
            isStream: true,
            isTransferable: defaults.TRANSFERABLE(),
            sender: params.admin,
            startTime: uint40(block.timestamp),
            wasCanceled: false
        });

        assertTrue(vars.merkleStreamerLL.hasClaimed(vars.indexes[params.posBeforeSort]));
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
