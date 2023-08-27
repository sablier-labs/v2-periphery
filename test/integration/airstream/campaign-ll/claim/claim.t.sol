// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Lockup, LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { Errors } from "src/libraries/Errors.sol";

import { Integration_Test } from "../../../Integration.t.sol";

contract Claim_Integration_Test is Integration_Test {
    function setUp() public virtual override {
        Integration_Test.setUp();
    }

    function test_RevertWhen_CampaignExpired() external {
        uint40 expiration = defaults.EXPIRATION();
        uint256 warpTime = expiration + 1;
        bytes32[] memory merkleProof;
        vm.warp({ timestamp: warpTime });
        vm.expectRevert(
            abi.encodeWithSelector(Errors.SablierV2AirstreamCampaign_CampaignHasExpired.selector, warpTime, expiration)
        );
        campaignLL.claim({ index: 1, recipient: users.recipient1.addr, amount: 1, merkleProof: merkleProof });
    }

    modifier whenCampaignHasNotExpired() {
        _;
    }

    function test_RevertWhen_AlreadyClaimed() external whenCampaignHasNotExpired {
        claimLL();
        uint256 index1 = defaults.INDEX1();
        uint128 amount = defaults.CLAIMABLE_AMOUNT();
        bytes32[] memory merkleProof = defaults.index1Proof();
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2AirstreamCampaign_AlreadyClaimed.selector, index1));
        campaignLL.claim(index1, users.recipient1.addr, amount, merkleProof);
    }

    modifier whenNotClaimed() {
        _;
    }

    modifier whenNotIncludedInMerkleTree() {
        _;
    }

    function test_RevertWhen_InvalidIndex()
        external
        whenCampaignHasNotExpired
        whenNotClaimed
        whenNotIncludedInMerkleTree
    {
        uint256 invalidIndex = defaults.INDEX2();
        uint128 amount = defaults.CLAIMABLE_AMOUNT();
        bytes32[] memory merkleProof = defaults.index1Proof();
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2AirstreamCampaign_InvalidProof.selector));
        campaignLL.claim(invalidIndex, users.recipient1.addr, amount, merkleProof);
    }

    function test_RevertWhen_InvalidRecipient()
        external
        whenCampaignHasNotExpired
        whenNotClaimed
        whenNotIncludedInMerkleTree
    {
        uint256 index1 = defaults.INDEX1();
        address invalidRecipient = users.recipient2.addr;
        uint128 amount = defaults.CLAIMABLE_AMOUNT();
        bytes32[] memory merkleProof = defaults.index1Proof();
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2AirstreamCampaign_InvalidProof.selector));
        campaignLL.claim(index1, invalidRecipient, amount, merkleProof);
    }

    function test_RevertWhen_InvalidAmount()
        external
        whenCampaignHasNotExpired
        whenNotClaimed
        whenNotIncludedInMerkleTree
    {
        uint256 index1 = defaults.INDEX1();
        uint128 invalidAmount = 1;
        bytes32[] memory merkleProof = defaults.index1Proof();
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2AirstreamCampaign_InvalidProof.selector));
        campaignLL.claim(index1, users.recipient1.addr, invalidAmount, merkleProof);
    }

    function test_RevertWhen_InvalidMerkleProof()
        external
        whenCampaignHasNotExpired
        whenNotClaimed
        whenNotIncludedInMerkleTree
    {
        uint256 index1 = defaults.INDEX1();
        uint128 amount = defaults.CLAIMABLE_AMOUNT();
        bytes32[] memory invalidMerkleProof = defaults.index2Proof();
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2AirstreamCampaign_InvalidProof.selector));
        campaignLL.claim(index1, users.recipient1.addr, amount, invalidMerkleProof);
    }

    modifier whenIncludedInMerkleTree() {
        _;
    }

    function test_Claim() external whenCampaignHasNotExpired whenNotClaimed whenIncludedInMerkleTree {
        uint256 expectedAirstreamId = lockupLinear.nextStreamId();

        vm.expectEmit();
        emit Claim(defaults.INDEX1(), users.recipient1.addr, defaults.CLAIMABLE_AMOUNT(), expectedAirstreamId);
        uint256 actualAirstreamId = claimLL();

        LockupLinear.Stream memory actualStream = lockupLinear.getStream(actualAirstreamId);
        LockupLinear.Stream memory expectedStream = LockupLinear.Stream({
            amounts: Lockup.Amounts({ deposited: defaults.CLAIMABLE_AMOUNT(), refunded: 0, withdrawn: 0 }),
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

        assertTrue(campaignLL.hasClaimed(defaults.INDEX1()));
        assertEq(actualAirstreamId, expectedAirstreamId);
        assertEq(actualStream, expectedStream);
    }
}
