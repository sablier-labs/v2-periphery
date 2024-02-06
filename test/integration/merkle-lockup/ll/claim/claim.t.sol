// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Lockup, LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";
import { ud, UD60x18 } from "@prb/math/src/UD60x18.sol";

import { Errors } from "src/libraries/Errors.sol";

import { MerkleLockup_Integration_Test } from "../../MerkleLockup.t.sol";

contract ClaimLL_Integration_Test is MerkleLockup_Integration_Test {
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
        merkleLockupLL.claim({ index: 1, recipient: users.recipient1, amount: 1, merkleProof: merkleProof });
    }

    modifier givenCampaignNotExpired() {
        _;
    }

    function test_RevertGiven_AlreadyClaimed() external givenCampaignNotExpired {
        claimLL();
        uint256 index1 = defaults.INDEX1();
        uint128 amount = defaults.CLAIM_AMOUNT();
        bytes32[] memory merkleProof = defaults.index1ProofLL();
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2MerkleLockup_StreamClaimed.selector, index1));
        merkleLockupLL.claim(index1, users.recipient1, amount, merkleProof);
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
        bytes32[] memory merkleProof = defaults.index1ProofLL();
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2MerkleLockup_InvalidProof.selector));
        merkleLockupLL.claim(invalidIndex, users.recipient1, amount, merkleProof);
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
        bytes32[] memory merkleProof = defaults.index1ProofLL();
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2MerkleLockup_InvalidProof.selector));
        merkleLockupLL.claim(index1, invalidRecipient, amount, merkleProof);
    }

    function test_RevertWhen_InvalidAmount()
        external
        givenCampaignNotExpired
        givenNotClaimed
        givenNotIncludedInMerkleTree
    {
        uint256 index1 = defaults.INDEX1();
        uint128 invalidAmount = 1337;
        bytes32[] memory merkleProof = defaults.index1ProofLL();
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2MerkleLockup_InvalidProof.selector));
        merkleLockupLL.claim(index1, users.recipient1, invalidAmount, merkleProof);
    }

    function test_RevertWhen_InvalidMerkleProof()
        external
        givenCampaignNotExpired
        givenNotClaimed
        givenNotIncludedInMerkleTree
    {
        uint256 index1 = defaults.INDEX1();
        uint128 amount = defaults.CLAIM_AMOUNT();
        bytes32[] memory invalidMerkleProof = defaults.index2ProofLL();
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2MerkleLockup_InvalidProof.selector));
        merkleLockupLL.claim(index1, users.recipient1, amount, invalidMerkleProof);
    }

    modifier givenIncludedInMerkleTree() {
        _;
    }

    function test_Claim_ProtocolFeeNotZero()
        external
        givenCampaignNotExpired
        givenNotClaimed
        givenIncludedInMerkleTree
    {
        changePrank({ msgSender: users.admin });
        comptroller.setProtocolFee({ asset: dai, newProtocolFee: ud(0.1e18) });

        test_Claim({ protocolFee: ud(0.1e18) });
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
        test_Claim({ protocolFee: ud(0) });
    }

    function test_Claim(UD60x18 protocolFee) internal {
        uint256 expectedStreamId = lockupLinear.nextStreamId();
        uint128 feeAmount = uint128(ud(defaults.CLAIM_AMOUNT()).mul(protocolFee).intoUint256());

        vm.expectEmit({ emitter: address(merkleLockupLL) });
        emit Claim(defaults.INDEX1(), users.recipient1, defaults.CLAIM_AMOUNT(), expectedStreamId);
        uint256 actualStreamId = claimLL();

        LockupLinear.Stream memory actualStream = lockupLinear.getStream(actualStreamId);
        LockupLinear.Stream memory expectedStream = LockupLinear.Stream({
            amounts: Lockup.Amounts({ deposited: defaults.CLAIM_AMOUNT() - feeAmount, refunded: 0, withdrawn: 0 }),
            asset: dai,
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

        assertTrue(merkleLockupLL.hasClaimed(defaults.INDEX1()), "not claimed");
        assertEq(actualStreamId, expectedStreamId, "invalid stream id");
        assertEq(actualStream, expectedStream);
    }
}
