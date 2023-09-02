// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Lockup, LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { Errors } from "src/libraries/Errors.sol";

import { Airstream_Integration_Test } from "../../Airstream.t.sol";

contract Claim_Integration_Test is Airstream_Integration_Test {
    function setUp() public virtual override {
        Airstream_Integration_Test.setUp();
    }

    function test_RevertWhen_CampaignExpired() external {
        uint40 expiration = defaults.EXPIRATION();
        uint256 warpTime = expiration + 1 seconds;
        bytes32[] memory merkleProof;
        vm.warp({ timestamp: warpTime });
        vm.expectRevert(
            abi.encodeWithSelector(Errors.SablierV2AirstreamCampaign_CampaignExpired.selector, warpTime, expiration)
        );
        campaignLL.claim({ index: 1, recipient: users.recipient1.addr, amount: 1, merkleProof: merkleProof });
    }

    modifier whenCampaignNotExpired() {
        _;
    }

    function test_RevertGiven_AlreadyClaimed() external whenCampaignNotExpired {
        claimLL();
        uint256 index1 = defaults.INDEX1();
        uint128 amount = defaults.CLAIM_AMOUNT();
        bytes32[] memory merkleProof = defaults.index1Proof();
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2AirstreamCampaign_AirstreamClaimed.selector, index1));
        campaignLL.claim(index1, users.recipient1.addr, amount, merkleProof);
    }

    modifier givenNotClaimed() {
        _;
    }

    modifier whenNotIncludedInMerkleTree() {
        _;
    }

    function test_RevertWhen_InvalidIndex()
        external
        whenCampaignNotExpired
        givenNotClaimed
        whenNotIncludedInMerkleTree
    {
        uint256 invalidIndex = 1337;
        uint128 amount = defaults.CLAIM_AMOUNT();
        bytes32[] memory merkleProof = defaults.index1Proof();
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2AirstreamCampaign_InvalidProof.selector));
        campaignLL.claim(invalidIndex, users.recipient1.addr, amount, merkleProof);
    }

    function test_RevertWhen_InvalidRecipient()
        external
        whenCampaignNotExpired
        givenNotClaimed
        whenNotIncludedInMerkleTree
    {
        uint256 index1 = defaults.INDEX1();
        address invalidRecipient = address(1337);
        uint128 amount = defaults.CLAIM_AMOUNT();
        bytes32[] memory merkleProof = defaults.index1Proof();
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2AirstreamCampaign_InvalidProof.selector));
        campaignLL.claim(index1, invalidRecipient, amount, merkleProof);
    }

    function test_RevertWhen_InvalidAmount()
        external
        whenCampaignNotExpired
        givenNotClaimed
        whenNotIncludedInMerkleTree
    {
        uint256 index1 = defaults.INDEX1();
        uint128 invalidAmount = 1337;
        bytes32[] memory merkleProof = defaults.index1Proof();
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2AirstreamCampaign_InvalidProof.selector));
        campaignLL.claim(index1, users.recipient1.addr, invalidAmount, merkleProof);
    }

    function test_RevertWhen_InvalidMerkleProof()
        external
        whenCampaignNotExpired
        givenNotClaimed
        whenNotIncludedInMerkleTree
    {
        uint256 index1 = defaults.INDEX1();
        uint128 amount = defaults.CLAIM_AMOUNT();
        bytes32[] memory invalidMerkleProof = defaults.index2Proof();
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2AirstreamCampaign_InvalidProof.selector));
        campaignLL.claim(index1, users.recipient1.addr, amount, invalidMerkleProof);
    }

    modifier whenIncludedInMerkleTree() {
        _;
    }

    function test_Claim() external whenCampaignNotExpired givenNotClaimed whenIncludedInMerkleTree {
        uint256 expectedAirstreamId = lockupLinear.nextStreamId();

        vm.expectEmit({ emitter: address(campaignLL) });
        emit Claim(defaults.INDEX1(), users.recipient1.addr, defaults.CLAIM_AMOUNT(), expectedAirstreamId);
        uint256 actualAirstreamId = claimLL();

        LockupLinear.Stream memory actualStream = lockupLinear.getStream(actualAirstreamId);
        LockupLinear.Stream memory expectedStream = LockupLinear.Stream({
            amounts: Lockup.Amounts({ deposited: defaults.CLAIM_AMOUNT(), refunded: 0, withdrawn: 0 }),
            asset: asset,
            cliffTime: uint40(block.timestamp) + defaults.CLIFF_DURATION(),
            endTime: uint40(block.timestamp) + defaults.TOTAL_DURATION(),
            isCancelable: defaults.CANCELABLE(),
            isDepleted: false,
            isStream: true,
            sender: users.admin.addr,
            startTime: uint40(block.timestamp),
            wasCanceled: false
        });

        assertTrue(campaignLL.hasClaimed(defaults.INDEX1()), "not claimed");
        assertEq(actualAirstreamId, expectedAirstreamId, "invalid airstream id");
        assertEq(actualStream, expectedStream);
    }
}
