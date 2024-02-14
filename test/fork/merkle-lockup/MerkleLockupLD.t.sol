// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Arrays } from "@openzeppelin/contracts/utils/Arrays.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Lockup, LockupDynamic } from "@sablier/v2-core/src/types/DataTypes.sol";

import { ISablierV2MerkleLockupLD } from "src/interfaces/ISablierV2MerkleLockupLD.sol";
import { MerkleLockup } from "src/types/DataTypes.sol";

import { MerkleBuilder } from "../../utils/MerkleBuilder.sol";
import { Fork_Test } from "../Fork.t.sol";

abstract contract MerkleLockupLD_Fork_Test is Fork_Test {
    using MerkleBuilder for uint256[];

    constructor(IERC20 asset_) Fork_Test(asset_) { }

    function setUp() public virtual override {
        Fork_Test.setUp();
    }

    /// @dev Encapsulates the data needed to compute a Merkle tree leaf.
    struct LeafData {
        uint256 index;
        uint256 recipientSeed;
        LockupDynamic.SegmentWithDuration[] segments;
    }

    struct Params {
        address admin;
        uint40 expiration;
        LeafData[] leafData;
        uint256 posBeforeSort;
    }

    struct Vars {
        uint256 actualStreamId;
        LockupDynamic.Stream actualStream;
        uint128[] amounts;
        uint256 aggregateAmount;
        uint128 clawbackAmount;
        address expectedLockupLD;
        MerkleLockup.ConstructorParams baseParams;
        uint40 endTime;
        LockupDynamic.Stream expectedStream;
        uint256 expectedStreamId;
        uint256[] indexes;
        uint256 leafPos;
        uint256 leafToClaim;
        ISablierV2MerkleLockupLD merkleLockupLD;
        bytes32 merkleRoot;
        address[] recipients;
        uint256 recipientsCount;
        LockupDynamic.SegmentWithDuration[][] segments;
        LockupDynamic.Segment[][] segmentsWithTimestamps;
    }

    // We need the leaves as a storage variable so that we can use OpenZeppelin's {Arrays.findUpperBound}.
    uint256[] public leaves;

    function testForkFuzz_MerkleLockupLD(Params memory params) external {
        vm.assume(params.admin != address(0) && params.admin != users.admin);
        vm.assume(params.expiration == 0 || params.expiration > block.timestamp);
        vm.assume(params.leafData.length > 1);
        params.posBeforeSort = _bound(params.posBeforeSort, 0, params.leafData.length - 1);
        assumeNoBlacklisted({ token: address(ASSET), addr: params.admin });

        /*//////////////////////////////////////////////////////////////////////////
                                          CREATE
        //////////////////////////////////////////////////////////////////////////*/

        Vars memory vars;

        vars.recipientsCount = params.leafData.length;
        vars.amounts = new uint128[](vars.recipientsCount);
        vars.indexes = new uint256[](vars.recipientsCount);
        vars.recipients = new address[](vars.recipientsCount);
        vars.segments = new LockupDynamic.SegmentWithDuration[][](vars.recipientsCount);
        vars.segmentsWithTimestamps = new LockupDynamic.Segment[][](vars.recipientsCount);

        for (uint256 i = 0; i < vars.recipientsCount; ++i) {
            vm.assume(params.leafData[i].segments.length > 0);
            vars.indexes[i] = params.leafData[i].index;

            // Bound each leaf's segment duration to avoid overflows.
            fuzzSegmentDurations(params.leafData[i].segments);

            (vars.amounts[i],) = fuzzDynamicStreamAmounts({
                upperBound: uint128(MAX_UINT128 / vars.recipientsCount - 1),
                segments: params.leafData[i].segments,
                protocolFee: defaults.PROTOCOL_FEE(),
                brokerFee: defaults.BROKER_FEE()
            });

            vars.aggregateAmount += vars.amounts[i];

            // Avoid zero recipient addresses.
            uint256 boundedRecipientSeed = _bound(params.leafData[i].recipientSeed, 1, type(uint160).max);
            vars.recipients[i] = address(uint160(boundedRecipientSeed));

            vars.segments[i] = params.leafData[i].segments;
            vars.segmentsWithTimestamps[i] = getSegmentsWithTimestamps(params.leafData[i].segments);
        }

        leaves = new uint256[](vars.recipientsCount);
        leaves = MerkleBuilder.computeLeavesLD(vars.indexes, vars.recipients, vars.amounts, vars.segments);

        // Sort the leaves in ascending order to match the production environment.
        MerkleBuilder.sortLeaves(leaves);
        vars.merkleRoot = getRoot(leaves.toBytes32());

        vars.expectedLockupLD = computeMerkleLockupLDAddress(params.admin, ASSET, vars.merkleRoot, params.expiration);

        vars.baseParams = defaults.baseParams({
            admin: params.admin,
            asset_: ASSET,
            merkleRoot: vars.merkleRoot,
            expiration: params.expiration
        });

        vm.expectEmit({ emitter: address(merkleLockupFactory) });
        emit CreateMerkleLockupLD({
            merkleLockupLD: ISablierV2MerkleLockupLD(vars.expectedLockupLD),
            baseParams: vars.baseParams,
            lockupDynamic: lockupDynamic,
            ipfsCID: defaults.IPFS_CID(),
            aggregateAmount: vars.aggregateAmount,
            recipientsCount: vars.recipientsCount
        });

        vars.merkleLockupLD = merkleLockupFactory.createMerkleLockupLD({
            baseParams: vars.baseParams,
            lockupDynamic: lockupDynamic,
            ipfsCID: defaults.IPFS_CID(),
            aggregateAmount: vars.aggregateAmount,
            recipientsCount: vars.recipientsCount
        });

        // Fund the Merkle Lockup contract.
        deal({ token: address(ASSET), to: address(vars.merkleLockupLD), give: vars.aggregateAmount });

        assertGt(address(vars.merkleLockupLD).code.length, 0, "MerkleLockupLD contract not created");
        assertEq(
            address(vars.merkleLockupLD),
            vars.expectedLockupLD,
            "MerkleLockupLD contract does not match computed address"
        );

        /*//////////////////////////////////////////////////////////////////////////
                                          CLAIM
        //////////////////////////////////////////////////////////////////////////*/

        assertFalse(vars.merkleLockupLD.hasClaimed(vars.indexes[params.posBeforeSort]));

        vars.leafToClaim = MerkleBuilder.computeLeafLD(
            vars.indexes[params.posBeforeSort],
            vars.recipients[params.posBeforeSort],
            vars.amounts[params.posBeforeSort],
            vars.segments[params.posBeforeSort]
        );
        vars.leafPos = Arrays.findUpperBound(leaves, vars.leafToClaim);

        vars.expectedStreamId = lockupDynamic.nextStreamId();
        emit Claim(
            vars.indexes[params.posBeforeSort],
            vars.recipients[params.posBeforeSort],
            vars.amounts[params.posBeforeSort],
            vars.expectedStreamId
        );
        vars.actualStreamId = vars.merkleLockupLD.claim({
            index: vars.indexes[params.posBeforeSort],
            recipient: vars.recipients[params.posBeforeSort],
            amount: vars.amounts[params.posBeforeSort],
            segments: vars.segments[params.posBeforeSort],
            merkleProof: getProof(leaves.toBytes32(), vars.leafPos)
        });

        vars.endTime = vars.segmentsWithTimestamps[params.posBeforeSort][params.leafData[params.posBeforeSort]
            .segments
            .length - 1].timestamp;

        vars.actualStream = lockupDynamic.getStream(vars.actualStreamId);
        vars.expectedStream = LockupDynamic.Stream({
            amounts: Lockup.Amounts({ deposited: vars.amounts[params.posBeforeSort], refunded: 0, withdrawn: 0 }),
            asset: ASSET,
            endTime: vars.endTime,
            isCancelable: defaults.CANCELABLE(),
            isDepleted: false,
            isStream: true,
            isTransferable: defaults.TRANSFERABLE(),
            segments: vars.segmentsWithTimestamps[params.posBeforeSort],
            sender: params.admin,
            startTime: uint40(block.timestamp),
            wasCanceled: false
        });

        assertTrue(vars.merkleLockupLD.hasClaimed(vars.indexes[params.posBeforeSort]));
        assertEq(vars.actualStreamId, vars.expectedStreamId);
        assertEq(vars.actualStream, vars.expectedStream);

        /*//////////////////////////////////////////////////////////////////////////
                                        CLAWBACK
        //////////////////////////////////////////////////////////////////////////*/

        if (params.expiration > 0) {
            vars.clawbackAmount = uint128(ASSET.balanceOf(address(vars.merkleLockupLD)));
            vm.warp({ timestamp: uint256(params.expiration) + 1 seconds });

            changePrank({ msgSender: params.admin });
            expectCallToTransfer({ asset_: address(ASSET), to: params.admin, amount: vars.clawbackAmount });
            vm.expectEmit({ emitter: address(vars.merkleLockupLD) });
            emit Clawback({ to: params.admin, admin: params.admin, amount: vars.clawbackAmount });
            vars.merkleLockupLD.clawback({ to: params.admin, amount: vars.clawbackAmount });
        }
    }
}
