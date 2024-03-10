// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Arrays } from "@openzeppelin/contracts/utils/Arrays.sol";
import { Lockup, LockupTranched } from "@sablier/v2-core/src/types/DataTypes.sol";

import { Errors } from "src/libraries/Errors.sol";
import { MerkleLockup } from "src/types/DataTypes.sol";
import { ISablierV2MerkleLockupLT } from "src/interfaces/ISablierV2MerkleLockupLT.sol";

import { Merkle } from "../../../../utils/Murky.sol";
import { MerkleBuilder } from "../../../../utils/MerkleBuilder.sol";

import { MerkleLockup_Integration_Test } from "../../MerkleLockup.t.sol";

contract Claim_Integration_Test is Merkle, MerkleLockup_Integration_Test {
    using MerkleBuilder for uint256[];

    function setUp() public virtual override {
        MerkleLockup_Integration_Test.setUp();
    }

    function test_RevertGiven_CampaignExpired() external {
        uint40 expiration = defaults.EXPIRATION();
        uint256 warpTime = expiration + 1 seconds;
        bytes32[] memory merkleProof;
        vm.warp({ timestamp: warpTime });
        vm.expectRevert(
            abi.encodeWithSelector(Errors.SablierV2MerkleLockup_CampaignExpired.selector, warpTime, expiration)
        );
        merkleLockupLT.claim({ index: 1, recipient: users.recipient1, amount: 1, merkleProof: merkleProof });
    }

    modifier givenCampaignNotExpired() {
        _;
    }

    function test_RevertGiven_AlreadyClaimed() external givenCampaignNotExpired {
        claimLT();
        uint256 index1 = defaults.INDEX1();
        uint128 amount = defaults.CLAIM_AMOUNT();
        bytes32[] memory merkleProof = defaults.index1Proof();
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2MerkleLockup_StreamClaimed.selector, index1));
        merkleLockupLT.claim(index1, users.recipient1, amount, merkleProof);
    }

    modifier givenNotClaimed() {
        _;
    }

    modifier givenNotIncludedInMerkleTree() {
        _;
    }

    function test_RevertWhen_InvalidIndex()
        external
        givenCampaignNotExpired
        givenNotClaimed
        givenNotIncludedInMerkleTree
    {
        uint256 invalidIndex = 1337;
        uint128 amount = defaults.CLAIM_AMOUNT();
        bytes32[] memory merkleProof = defaults.index1Proof();
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2MerkleLockup_InvalidProof.selector));
        merkleLockupLT.claim(invalidIndex, users.recipient1, amount, merkleProof);
    }

    function test_RevertWhen_InvalidRecipient()
        external
        givenCampaignNotExpired
        givenNotClaimed
        givenNotIncludedInMerkleTree
    {
        uint256 index1 = defaults.INDEX1();
        address invalidRecipient = address(1337);
        uint128 amount = defaults.CLAIM_AMOUNT();
        bytes32[] memory merkleProof = defaults.index1Proof();
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2MerkleLockup_InvalidProof.selector));
        merkleLockupLT.claim(index1, invalidRecipient, amount, merkleProof);
    }

    function test_RevertWhen_InvalidAmount()
        external
        givenCampaignNotExpired
        givenNotClaimed
        givenNotIncludedInMerkleTree
    {
        uint256 index1 = defaults.INDEX1();
        uint128 invalidAmount = 1337;
        bytes32[] memory merkleProof = defaults.index1Proof();
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2MerkleLockup_InvalidProof.selector));
        merkleLockupLT.claim(index1, users.recipient1, invalidAmount, merkleProof);
    }

    function test_RevertWhen_InvalidMerkleProof()
        external
        givenCampaignNotExpired
        givenNotClaimed
        givenNotIncludedInMerkleTree
    {
        uint256 index1 = defaults.INDEX1();
        uint128 amount = defaults.CLAIM_AMOUNT();
        bytes32[] memory invalidMerkleProof = defaults.index2Proof();
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2MerkleLockup_InvalidProof.selector));
        merkleLockupLT.claim(index1, users.recipient1, amount, invalidMerkleProof);
    }

    modifier givenIncludedInMerkleTree() {
        _;
    }

    // Needed this variables in storage due to how the imported libaries work.
    uint256[] public leaves = new uint256[](4); // same number of recipients as in the defaults

    function test_Claim_TrancheAmountCalculationRoundingError()
        external
        givenCampaignNotExpired
        givenNotClaimed
        givenIncludedInMerkleTree
    {
        // Declare an amount that will cause a rounding error.
        uint128 claimAmount = 340_282_366_920_938_463_463_374_607_431_768_211_453;
        uint256 aggregateAmount = defaults.CLAIM_AMOUNT() * 3 + uint256(claimAmount);

        // Compute the Merkle tree.
        leaves = defaults.getLeaves();
        leaves[0] = MerkleBuilder.computeLeaf(defaults.INDEX1(), users.recipient1, claimAmount);
        MerkleBuilder.sortLeaves(leaves);
        bytes32 merkleRoot = getRoot(leaves.toBytes32());

        // Compute the Merkle proof.
        uint256 leaf = MerkleBuilder.computeLeaf(defaults.INDEX1(), users.recipient1, claimAmount);
        uint256 pos = Arrays.findUpperBound(leaves, leaf);
        bytes32[] memory proof = getProof(leaves.toBytes32(), pos);

        /// Declare the constructor params.
        MerkleLockup.ConstructorParams memory baseParams = defaults.baseParams();
        baseParams.merkleRoot = merkleRoot;

        // Deploy the new MerkleLockupLT contract.
        ISablierV2MerkleLockupLT _merkleLockupLT = merkleLockupFactory.createMerkleLockupLT(
            baseParams, lockupTranched, defaults.tranchesWithPercentages(), aggregateAmount, defaults.RECIPIENTS_COUNT()
        );

        // Fund the MerkleLockupLT contract.
        deal({ token: address(dai), to: address(_merkleLockupLT), give: aggregateAmount });

        uint256 expectedStreamId = lockupTranched.nextStreamId();

        vm.expectEmit({ emitter: address(_merkleLockupLT) });
        emit Claim(defaults.INDEX1(), users.recipient1, claimAmount, expectedStreamId);
        uint256 actualStreamId = _merkleLockupLT.claim(defaults.INDEX1(), users.recipient1, claimAmount, proof);

        LockupTranched.StreamLT memory actualStream = lockupTranched.getStream(actualStreamId);
        LockupTranched.StreamLT memory expectedStream = LockupTranched.StreamLT({
            amounts: Lockup.Amounts({ deposited: claimAmount, refunded: 0, withdrawn: 0 }),
            asset: dai,
            endTime: uint40(block.timestamp) + defaults.TOTAL_DURATION(),
            isCancelable: defaults.CANCELABLE(),
            isDepleted: false,
            isStream: true,
            isTransferable: defaults.TRANSFERABLE(),
            sender: users.admin,
            startTime: uint40(block.timestamp),
            tranches: defaults.tranches(claimAmount),
            wasCanceled: false
        });

        assertTrue(_merkleLockupLT.hasClaimed(defaults.INDEX1()), "not claimed");
        assertEq(actualStreamId, expectedStreamId, "invalid stream id");
        assertEq(actualStream, expectedStream);
    }

    function test_Claim() external {
        uint256 expectedStreamId = lockupTranched.nextStreamId();

        vm.expectEmit({ emitter: address(merkleLockupLT) });
        emit Claim(defaults.INDEX1(), users.recipient1, defaults.CLAIM_AMOUNT(), expectedStreamId);
        uint256 actualStreamId = claimLT();

        LockupTranched.Tranche[] memory tranches = defaults.tranches();

        LockupTranched.StreamLT memory actualStream = lockupTranched.getStream(actualStreamId);
        LockupTranched.StreamLT memory expectedStream = LockupTranched.StreamLT({
            amounts: Lockup.Amounts({ deposited: defaults.CLAIM_AMOUNT(), refunded: 0, withdrawn: 0 }),
            asset: dai,
            endTime: uint40(block.timestamp) + defaults.TOTAL_DURATION(),
            isCancelable: defaults.CANCELABLE(),
            isDepleted: false,
            isStream: true,
            isTransferable: defaults.TRANSFERABLE(),
            sender: users.admin,
            startTime: uint40(block.timestamp),
            tranches: tranches,
            wasCanceled: false
        });

        assertTrue(merkleLockupLT.hasClaimed(defaults.INDEX1()), "not claimed");
        assertEq(actualStreamId, expectedStreamId, "invalid stream id");
        assertEq(actualStream, expectedStream);
    }
}
