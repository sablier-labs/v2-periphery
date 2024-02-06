// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Lockup, LockupDynamic } from "@sablier/v2-core/src/types/DataTypes.sol";
import { ud, UD60x18 } from "@prb/math/src/UD60x18.sol";

import { Errors } from "src/libraries/Errors.sol";

import { MerkleLockup_Integration_Test } from "../../MerkleLockup.t.sol";

contract ClaimLD_Integration_Test is MerkleLockup_Integration_Test {
    function setUp() public virtual override {
        MerkleLockup_Integration_Test.setUp();
    }

    function test_RevertGiven_CampaignExpired() external {
        uint40 expiration = defaults.EXPIRATION();
        uint256 warpTime = expiration + 1 seconds;
        LockupDynamic.SegmentWithDuration[] memory segments = defaults.segmentsWithDurations();
        bytes32[] memory merkleProof;
        vm.warp({ timestamp: warpTime });
        vm.expectRevert(
            abi.encodeWithSelector(Errors.SablierV2MerkleLockup_CampaignExpired.selector, warpTime, expiration)
        );
        merkleLockupLD.claim({
            index: 1,
            recipient: users.recipient1,
            amount: 1,
            segments: segments,
            merkleProof: merkleProof
        });
    }

    modifier givenCampaignNotExpired() {
        _;
    }

    function test_RevertGiven_AlreadyClaimed() external givenCampaignNotExpired {
        claimLD();
        uint256 index1 = defaults.INDEX1();
        uint128 amount = defaults.CLAIM_AMOUNT();
        LockupDynamic.SegmentWithDuration[] memory segments = defaults.segmentsWithDurations();
        bytes32[] memory merkleProof = defaults.index1ProofLD();
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2MerkleLockup_StreamClaimed.selector, index1));
        merkleLockupLD.claim({
            index: index1,
            recipient: users.recipient1,
            amount: amount,
            segments: segments,
            merkleProof: merkleProof
        });
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
        LockupDynamic.SegmentWithDuration[] memory segments = defaults.segmentsWithDurations();
        bytes32[] memory merkleProof = defaults.index1ProofLD();
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2MerkleLockup_InvalidProof.selector));
        merkleLockupLD.claim({
            index: invalidIndex,
            recipient: users.recipient1,
            amount: amount,
            segments: segments,
            merkleProof: merkleProof
        });
    }

    function test_RevertWhen_InvalidRecipient()
        external
        givenCampaignNotExpired
        givenNotClaimed
        givenNotIncludedInMerkleTree
    {
        uint256 index1 = defaults.INDEX1();
        uint128 amount = defaults.CLAIM_AMOUNT();
        address invalidRecipient = address(1337);
        LockupDynamic.SegmentWithDuration[] memory segments = defaults.segmentsWithDurations();
        bytes32[] memory merkleProof = defaults.index1ProofLD();
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2MerkleLockup_InvalidProof.selector));
        merkleLockupLD.claim({
            index: index1,
            recipient: invalidRecipient,
            amount: amount,
            segments: segments,
            merkleProof: merkleProof
        });
    }

    function test_RevertWhen_InvalidAmount()
        external
        givenCampaignNotExpired
        givenNotClaimed
        givenNotIncludedInMerkleTree
    {
        uint256 index1 = defaults.INDEX1();
        uint128 invalidAmount = 1337;
        address invalidRecipient = address(1337);
        LockupDynamic.SegmentWithDuration[] memory segments = defaults.segmentsWithDurations();
        bytes32[] memory merkleProof = defaults.index1ProofLD();
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2MerkleLockup_InvalidProof.selector));
        merkleLockupLD.claim({
            index: index1,
            recipient: invalidRecipient,
            amount: invalidAmount,
            segments: segments,
            merkleProof: merkleProof
        });
    }

    function test_RevertWhen_InvalidSegments()
        external
        givenCampaignNotExpired
        givenNotClaimed
        givenNotIncludedInMerkleTree
    {
        uint256 index1 = defaults.INDEX1();
        uint128 amount = defaults.CLAIM_AMOUNT();
        LockupDynamic.SegmentWithDuration[] memory segmentsWithInvalidAmounts =
            defaults.segmentsWithDurations(1000, 8000);
        bytes32[] memory merkleProof = defaults.index1ProofLD();
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2MerkleLockup_InvalidProof.selector));
        merkleLockupLD.claim({
            index: index1,
            recipient: users.recipient1,
            amount: amount,
            segments: segmentsWithInvalidAmounts,
            merkleProof: merkleProof
        });
    }

    function test_RevertWhen_InvalidMerkleProof()
        external
        givenCampaignNotExpired
        givenNotClaimed
        givenNotIncludedInMerkleTree
    {
        uint256 index1 = defaults.INDEX1();
        uint128 amount = defaults.CLAIM_AMOUNT();
        LockupDynamic.SegmentWithDuration[] memory segments = defaults.segmentsWithDurations();
        bytes32[] memory invalidMerkleProof = defaults.index2ProofLD();
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2MerkleLockup_InvalidProof.selector));
        merkleLockupLD.claim({
            index: index1,
            recipient: users.recipient1,
            amount: amount,
            segments: segments,
            merkleProof: invalidMerkleProof
        });
    }

    modifier givenIncludedInMerkleTree() {
        _;
    }

    modifier givenProtocolFeeZero() {
        _;
    }

    function test_Claim()
        external
        givenCampaignNotExpired
        givenNotClaimed
        givenIncludedInMerkleTree
        givenProtocolFeeZero
    {
        uint256 expectedStreamId = lockupDynamic.nextStreamId();

        vm.expectEmit({ emitter: address(merkleLockupLD) });
        emit Claim(defaults.INDEX1(), users.recipient1, defaults.CLAIM_AMOUNT(), expectedStreamId);
        uint256 actualStreamId = claimLD();

        LockupDynamic.Stream memory actualStream = lockupDynamic.getStream(actualStreamId);
        LockupDynamic.Stream memory expectedStream = LockupDynamic.Stream({
            amounts: Lockup.Amounts({ deposited: defaults.CLAIM_AMOUNT(), refunded: 0, withdrawn: 0 }),
            asset: asset,
            endTime: uint40(block.timestamp) + defaults.TOTAL_DURATION(),
            isCancelable: defaults.CANCELABLE(),
            isDepleted: false,
            isStream: true,
            isTransferable: defaults.TRANSFERABLE(),
            segments: defaults.segments(),
            sender: users.admin,
            startTime: uint40(block.timestamp),
            wasCanceled: false
        });

        assertTrue(merkleLockupLD.hasClaimed(defaults.INDEX1()), "not claimed");
        assertEq(actualStreamId, expectedStreamId, "invalid stream id");
        assertEq(actualStream, expectedStream);
    }
}
