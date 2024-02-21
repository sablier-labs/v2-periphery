// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Arrays } from "@openzeppelin/contracts/utils/Arrays.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Lockup, LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { ISablierV2MerkleLockupLL } from "src/interfaces/ISablierV2MerkleLockupLL.sol";
import { MerkleLockup } from "src/types/DataTypes.sol";

import { MerkleBuilder } from "../../utils/MerkleBuilder.sol";
import { Fork_Test } from "../Fork.t.sol";

abstract contract MerkleLockupLL_Fork_Test is Fork_Test {
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
        LockupLinear.StreamLL actualStream;
        uint128[] amounts;
        uint256 aggregateAmount;
        uint128 clawbackAmount;
        address expectedLockupLL;
        MerkleLockup.ConstructorParams baseParams;
        LockupLinear.StreamLL expectedStream;
        uint256 expectedStreamId;
        uint256[] indexes;
        uint256 leafPos;
        uint256 leafToClaim;
        ISablierV2MerkleLockupLL merkleLockupLL;
        bytes32 merkleRoot;
        address[] recipients;
        uint256 recipientsCount;
    }

    // We need the leaves as a storage variable so that we can use OpenZeppelin's {Arrays.findUpperBound}.
    uint256[] public leaves;

    function testForkFuzz_MerkleLockupLL(Params memory params) external {
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
        for (uint256 i = 0; i < vars.recipientsCount; ++i) {
            vars.indexes[i] = params.leafData[i].index;

            // Bound each leaf amount so that `aggregateAmount` does not overflow.
            params.leafData[i].amount =
                uint128(_bound(params.leafData[i].amount, 1, MAX_UINT256 / vars.recipientsCount - 1));
            vars.amounts[i] = params.leafData[i].amount;
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

        vars.expectedLockupLL = computeMerkleLockupLLAddress(params.admin, ASSET, vars.merkleRoot, params.expiration);

        vars.baseParams = defaults.baseParams({
            admin: params.admin,
            asset_: ASSET,
            merkleRoot: vars.merkleRoot,
            expiration: params.expiration
        });

        vm.expectEmit({ emitter: address(merkleLockupFactory) });
        emit CreateMerkleLockupLL({
            merkleLockupLL: ISablierV2MerkleLockupLL(vars.expectedLockupLL),
            baseParams: vars.baseParams,
            lockupLinear: lockupLinear,
            streamDurations: defaults.durations(),
            ipfsCID: defaults.IPFS_CID(),
            aggregateAmount: vars.aggregateAmount,
            recipientsCount: vars.recipientsCount
        });

        vars.merkleLockupLL = merkleLockupFactory.createMerkleLockupLL({
            baseParams: vars.baseParams,
            lockupLinear: lockupLinear,
            streamDurations: defaults.durations(),
            ipfsCID: defaults.IPFS_CID(),
            aggregateAmount: vars.aggregateAmount,
            recipientsCount: vars.recipientsCount
        });

        // Fund the Merkle Lockup contract.
        deal({ token: address(ASSET), to: address(vars.merkleLockupLL), give: vars.aggregateAmount });

        assertGt(address(vars.merkleLockupLL).code.length, 0, "MerkleLockupLL contract not created");
        assertEq(
            address(vars.merkleLockupLL),
            vars.expectedLockupLL,
            "MerkleLockupLL contract does not match computed address"
        );

        /*//////////////////////////////////////////////////////////////////////////
                                          CLAIM
        //////////////////////////////////////////////////////////////////////////*/

        assertFalse(vars.merkleLockupLL.hasClaimed(vars.indexes[params.posBeforeSort]));

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
        vars.actualStreamId = vars.merkleLockupLL.claim({
            index: vars.indexes[params.posBeforeSort],
            recipient: vars.recipients[params.posBeforeSort],
            amount: vars.amounts[params.posBeforeSort],
            merkleProof: getProof(leaves.toBytes32(), vars.leafPos)
        });

        vars.actualStream = lockupLinear.getStream(vars.actualStreamId);
        vars.expectedStream = LockupLinear.StreamLL({
            amounts: Lockup.Amounts({ deposited: vars.amounts[params.posBeforeSort], refunded: 0, withdrawn: 0 }),
            asset: ASSET,
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

        assertTrue(vars.merkleLockupLL.hasClaimed(vars.indexes[params.posBeforeSort]));
        assertEq(vars.actualStreamId, vars.expectedStreamId);
        assertEq(vars.actualStream, vars.expectedStream);

        /*//////////////////////////////////////////////////////////////////////////
                                        CLAWBACK
        //////////////////////////////////////////////////////////////////////////*/

        if (params.expiration > 0) {
            vars.clawbackAmount = uint128(ASSET.balanceOf(address(vars.merkleLockupLL)));
            vm.warp({ timestamp: uint256(params.expiration) + 1 seconds });

            changePrank({ msgSender: params.admin });
            expectCallToTransfer({ asset_: address(ASSET), to: params.admin, amount: vars.clawbackAmount });
            vm.expectEmit({ emitter: address(vars.merkleLockupLL) });
            emit Clawback({ to: params.admin, admin: params.admin, amount: vars.clawbackAmount });
            vars.merkleLockupLL.clawback({ to: params.admin, amount: vars.clawbackAmount });
        }
    }
}
