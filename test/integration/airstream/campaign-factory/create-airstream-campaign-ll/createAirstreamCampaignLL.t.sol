// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { ISablierV2AirstreamCampaignLL } from "src/interfaces/ISablierV2AirstreamCampaignLL.sol";

import { Airstream_Integration_Test } from "../../Airstream.t.sol";

contract CreateAirstreamCampaignLL_Integration_Test is Airstream_Integration_Test {
    function setUp() public override {
        Airstream_Integration_Test.setUp();
    }

    /// @dev This test works because a default campaign is deployed in {Integration_Test.setUp}
    function test_RevertGiven_AlreadyDeployed() external {
        bytes32 merkleRoot = defaults.merkleRoot();
        uint40 expiration = defaults.EXPIRATION();
        bool cancelable = defaults.CANCELABLE();
        LockupLinear.Durations memory airstreamDurations = defaults.durations();
        string memory ipfsCID = defaults.IPFS_CID();
        uint256 campaignTotalAmount = defaults.CAMPAIGN_TOTAL_AMOUNT();
        uint256 recipientsCount = defaults.RECIPIENTS_COUNT();

        vm.expectRevert();
        campaignFactory.createAirstreamCampaignLL({
            initialAdmin: users.admin.addr,
            lockupLinear: lockupLinear,
            asset: asset,
            merkleRoot: merkleRoot,
            expiration: expiration,
            cancelable: cancelable,
            airstreamDurations: airstreamDurations,
            ipfsCID: ipfsCID,
            campaignTotalAmount: campaignTotalAmount,
            recipientsCount: recipientsCount
        });
    }

    modifier givenNotAlreadyDeployed() {
        _;
    }

    function testFuzz_CreateAirstreamCampaignLL(address admin, uint40 expiration) external givenNotAlreadyDeployed {
        vm.assume(admin != users.admin.addr);
        address expectedCampaignLL = computeCampaignLLAddress(admin, expiration);

        vm.expectEmit({ emitter: address(campaignFactory) });
        emit CreateAirstreamCampaignLL({
            airstreamCampaign: ISablierV2AirstreamCampaignLL(expectedCampaignLL),
            admin: admin,
            lockupLinear: lockupLinear,
            asset: asset,
            expiration: expiration,
            airstreamDurations: defaults.durations(),
            cancelable: defaults.CANCELABLE(),
            ipfsCID: defaults.IPFS_CID(),
            campaignTotalAmount: defaults.CAMPAIGN_TOTAL_AMOUNT(),
            recipientsCount: defaults.RECIPIENTS_COUNT()
        });

        address actualCampaignLL = address(createAirstreamCampaignLL(admin, expiration));
        ISablierV2AirstreamCampaignLL[] memory expectedCampaigns = campaignFactory.getAirstreamCampaigns(admin);
        assertGt(actualCampaignLL.code.length, 0, "CampaignLL contract not created");
        assertEq(actualCampaignLL, expectedCampaignLL, "CampaignLL contract does not match computed address");
        assertEq(actualCampaignLL, address(expectedCampaigns[0]), "CampaignLL contract not stored in the mapping");
    }
}
