// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Lockup, LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { ISablierV2AirstreamCampaignLL } from "src/interfaces/ISablierV2AirstreamCampaignLL.sol";

import { MerkleBuilder } from "../../utils/MerkleBuilder.sol";
import { Fork_Test } from "../Fork.t.sol";

abstract contract CampaignLL_Fork_Test is Fork_Test {
    constructor(IERC20 asset_) Fork_Test(asset_) { }

    function setUp() public virtual override {
        Fork_Test.setUp();
    }

    /// @dev Encapsulates the data needed to compute a Merkle tree leaf.
    struct LeafData {
        uint256 index;
        address recipient;
        uint128 amount;
    }

    struct Params {
        address admin;
        LeafData[] leafData;
        uint256 leafPos;
    }

    struct Vars {
        uint256 dataCount;
        uint256 campaignTotalAmount;
        uint256[] indexes;
        address[] recipients;
        uint128[] amounts;
        bytes32[] leaves;
        bytes32 merkleRoot;
        address computedCampaignLL;
        ISablierV2AirstreamCampaignLL campaignLL;
        uint256 actualAirstreamId;
        uint256 expectedAirstreamId;
        LockupLinear.Stream actualStream;
        LockupLinear.Stream expectedStream;
        uint128 clawbackAmount;
    }

    function testForkFuzz_ClaimHasClaimedClawback(Params memory params) external {
        vm.assume(params.admin != users.admin.addr);
        vm.assume(params.leafData.length > 250);
        vm.assume(params.leafPos < params.leafData.length);

        // Bound each amount so that `campaignTotalAmount` does not overflow.
        for (uint256 i = 0; i < params.leafData.length; ++i) {
            params.leafData[i].amount =
                uint128(_bound(params.leafData[i].amount, 1, MAX_UINT256 / params.leafData.length - 1));
        }

        Vars memory vars;

        vars.dataCount = params.leafData.length;
        for (uint256 i = 0; i < vars.dataCount; ++i) {
            vars.campaignTotalAmount += params.leafData[i].amount;
        }

        vars.indexes = new uint256[](vars.dataCount);
        vars.recipients = new address[](vars.dataCount);
        vars.amounts = new uint128[](vars.dataCount);
        for (uint256 i = 0; i < vars.dataCount; ++i) {
            vars.indexes[i] = params.leafData[i].index;
            vars.recipients[i] = params.leafData[i].recipient;
            vars.amounts[i] = params.leafData[i].amount;
        }

        // Compute the Merkle leaves and root.
        vars.leaves = MerkleBuilder.computeLeaves(vars.indexes, vars.recipients, vars.amounts);
        vars.merkleRoot = MerkleBuilder.computeRoot(vars.leaves);

        vars.computedCampaignLL = computeCampaignLLAddress(params.admin, vars.merkleRoot);
        vm.expectEmit({ emitter: address(campaignFactory) });
        emit CreateAirstreamCampaignLL(
            params.admin,
            asset,
            ISablierV2AirstreamCampaignLL(vars.computedCampaignLL),
            defaults.IPFS_CID(),
            vars.campaignTotalAmount,
            vars.dataCount
        );

        // Create the campaign.
        vars.campaignLL = campaignFactory.createAirstreamCampaignLL(
            params.admin,
            asset,
            vars.merkleRoot,
            defaults.CANCELABLE(),
            defaults.EXPIRATION(),
            lockupLinear,
            defaults.durations(),
            defaults.IPFS_CID(),
            vars.campaignTotalAmount,
            vars.dataCount
        );

        assertTrue(address(vars.campaignLL).code.length > 0, "campaignLL was not created");
        assertEq(address(vars.campaignLL), vars.computedCampaignLL, "campaignLL does not match computed address");

        // Fund the campaign.
        deal({ token: address(asset), to: address(vars.campaignLL), give: vars.campaignTotalAmount });

        vars.expectedAirstreamId = lockupLinear.nextStreamId();

        assertFalse(vars.campaignLL.hasClaimed(vars.indexes[params.leafPos]));

        emit Claim(
            vars.indexes[params.leafPos],
            vars.recipients[params.leafPos],
            vars.amounts[params.leafPos],
            vars.expectedAirstreamId
        );
        vars.actualAirstreamId = vars.campaignLL.claim({
            index: vars.indexes[params.leafPos],
            recipient: vars.recipients[params.leafPos],
            amount: vars.amounts[params.leafPos],
            merkleProof: MerkleBuilder.computeProof(vars.leaves, params.leafPos)
        });

        vars.actualStream = lockupLinear.getStream(vars.actualAirstreamId);
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

        assertTrue(vars.campaignLL.hasClaimed(vars.indexes[params.leafPos]));
        assertEq(vars.actualAirstreamId, vars.expectedAirstreamId);
        assertEq(vars.actualStream, vars.expectedStream);

        vars.clawbackAmount = uint128(asset.balanceOf(address(vars.campaignLL)));
        vm.warp({ timestamp: defaults.EXPIRATION() + 1 });

        changePrank({ msgSender: params.admin });
        expectCallToTransfer({ to: params.admin, amount: vars.clawbackAmount });
        vm.expectEmit();
        emit Clawback({ to: params.admin, admin: params.admin, amount: vars.clawbackAmount });
        vars.campaignLL.clawback({ to: params.admin, amount: vars.clawbackAmount });
    }
}
