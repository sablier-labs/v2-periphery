// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Lockup, LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";
import { ud } from "@prb/math/src/UD60x18.sol";

import { Errors } from "src/libraries/Errors.sol";

import { MerkleStreamer_Integration_Test } from "../../MerkleStreamer.t.sol";

contract Claim_Integration_Test is MerkleStreamer_Integration_Test {
    function setUp() public virtual override {
        MerkleStreamer_Integration_Test.setUp();
    }

    function test_RevertGiven_CampaignExpired() external {
        uint40 expiration = defaults.EXPIRATION();
        uint256 warpTime = expiration + 1 seconds;
        bytes32[] memory merkleProof;
        vm.warp({ timestamp: warpTime });
        vm.expectRevert(
            abi.encodeWithSelector(Errors.SablierV2MerkleStreamer_CampaignExpired.selector, warpTime, expiration)
        );
        merkleStreamerLL.claim({ index: 1, recipient: users.recipient1, amount: 1, merkleProof: merkleProof });
    }

    modifier givenCampaignNotExpired() {
        _;
    }

    function test_RevertGiven_AlreadyClaimed() external givenCampaignNotExpired {
        claimLL();
        uint256 index1 = defaults.INDEX1();
        uint128 amount = defaults.CLAIM_AMOUNT();
        bytes32[] memory merkleProof = defaults.index1Proof();
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2MerkleStreamer_StreamClaimed.selector, index1));
        merkleStreamerLL.claim(index1, users.recipient1, amount, merkleProof);
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
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2MerkleStreamer_InvalidProof.selector));
        merkleStreamerLL.claim(invalidIndex, users.recipient1, amount, merkleProof);
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
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2MerkleStreamer_InvalidProof.selector));
        merkleStreamerLL.claim(index1, invalidRecipient, amount, merkleProof);
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
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2MerkleStreamer_InvalidProof.selector));
        merkleStreamerLL.claim(index1, users.recipient1, invalidAmount, merkleProof);
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
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2MerkleStreamer_InvalidProof.selector));
        merkleStreamerLL.claim(index1, users.recipient1, amount, invalidMerkleProof);
    }

    modifier givenIncludedInMerkleTree() {
        _;
    }

    function test_RevertGiven_ProtocolFeeNotZero()
        external
        givenCampaignNotExpired
        givenNotClaimed
        givenIncludedInMerkleTree
    {
        uint128 claimAmount = defaults.CLAIM_AMOUNT();
        bytes32[] memory merkleProof = defaults.index1Proof();
        changePrank({ msgSender: users.admin });
        comptroller.setProtocolFee({ asset: asset, newProtocolFee: ud(0.1e18) });
        vm.expectRevert(Errors.SablierV2MerkleStreamer_ProtocolFeeNotZero.selector);
        merkleStreamerLL.claim({ index: 1, recipient: users.recipient1, amount: claimAmount, merkleProof: merkleProof });
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
        uint256 expectedStreamId = lockupLinear.nextStreamId();

        vm.expectEmit({ emitter: address(merkleStreamerLL) });
        emit Claim(defaults.INDEX1(), users.recipient1, defaults.CLAIM_AMOUNT(), expectedStreamId);
        uint256 actualStreamId = claimLL();

        LockupLinear.Stream memory actualStream = lockupLinear.getStream(actualStreamId);
        LockupLinear.Stream memory expectedStream = LockupLinear.Stream({
            amounts: Lockup.Amounts({ deposited: defaults.CLAIM_AMOUNT(), refunded: 0, withdrawn: 0 }),
            asset: asset,
            cliffTime: uint40(block.timestamp) + defaults.CLIFF_DURATION(),
            endTime: uint40(block.timestamp) + defaults.TOTAL_DURATION(),
            isCancelable: defaults.CANCELABLE(),
            isDepleted: false,
            isStream: true,
            isTransferable: defaults.TRANSFERABLE(),
            sender: users.admin,
            startTime: uint40(block.timestamp),
            wasCanceled: false
        });

        assertTrue(merkleStreamerLL.hasClaimed(defaults.INDEX1()), "not claimed");
        assertEq(actualStreamId, expectedStreamId, "invalid stream id");
        assertEq(actualStream, expectedStream);
    }
}
