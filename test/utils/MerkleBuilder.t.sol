// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { StdUtils } from "forge-std/src/StdUtils.sol";
import { LockupDynamic } from "@sablier/v2-core/src/types/DataTypes.sol";

import { MerkleBuilder } from "./MerkleBuilder.sol";

contract MerkleBuilder_Test is PRBTest, StdUtils {
    /*//////////////////////////////////////////////////////////////////////////
                                  MERKLE-LEAF-LD
    //////////////////////////////////////////////////////////////////////////*/

    function testFuzz_ComputeLeafLD(
        uint256 index,
        address recipient,
        uint128 amount,
        LockupDynamic.SegmentWithDuration[] memory segments
    )
        external
    {
        uint256 actualLeaf = MerkleBuilder.computeLeafLD(index, recipient, amount, segments);
        uint256 expectedLeaf =
            uint256(keccak256(bytes.concat(keccak256(abi.encode(index, recipient, amount, segments)))));
        assertEq(actualLeaf, expectedLeaf, "computeLeafLD");
    }

    /// @dev We declare this struct so that we will not need cheatcodes in the `computeLeavesLD` test.
    struct LeavesParamsLD {
        uint256 indexes;
        address recipients;
        uint128 amounts;
        LockupDynamic.SegmentWithDuration[] segments;
    }

    function testFuzz_ComputeLeavesLD(LeavesParamsLD[] memory params) external {
        uint256 count = params.length;

        uint256[] memory indexes = new uint256[](count);
        address[] memory recipients = new address[](count);
        uint128[] memory amounts = new uint128[](count);
        LockupDynamic.SegmentWithDuration[][] memory segments = new LockupDynamic.SegmentWithDuration[][](count);
        for (uint256 i = 0; i < count; ++i) {
            indexes[i] = params[i].indexes;
            recipients[i] = params[i].recipients;
            amounts[i] = params[i].amounts;
            segments[i] = params[i].segments;
        }

        uint256[] memory actualLeaves = new uint256[](count);
        actualLeaves = MerkleBuilder.computeLeavesLD(indexes, recipients, amounts, segments);

        uint256[] memory expectedLeaves = new uint256[](count);
        for (uint256 i = 0; i < count; ++i) {
            expectedLeaves[i] = uint256(
                keccak256(bytes.concat(keccak256(abi.encode(indexes[i], recipients[i], amounts[i], segments[i]))))
            );
        }

        assertEq(actualLeaves, expectedLeaves, "computeLeavesLD");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  MERKLE-LEAF-LL
    //////////////////////////////////////////////////////////////////////////*/

    function testFuzz_ComputeLeafLL(uint256 index, address recipient, uint128 amount) external {
        uint256 actualLeaf = MerkleBuilder.computeLeafLL(index, recipient, amount);
        uint256 expectedLeaf = uint256(keccak256(bytes.concat(keccak256(abi.encode(index, recipient, amount)))));
        assertEq(actualLeaf, expectedLeaf, "computeLeafLL");
    }

    /// @dev We declare this struct so that we will not need cheatcodes in the `computeLeavesLL` test.
    struct LeavesParamsLL {
        uint256 indexes;
        address recipients;
        uint128 amounts;
    }

    function testFuzz_ComputeLeavesLL(LeavesParamsLL[] memory params) external {
        uint256 count = params.length;

        uint256[] memory indexes = new uint256[](count);
        address[] memory recipients = new address[](count);
        uint128[] memory amounts = new uint128[](count);
        for (uint256 i = 0; i < count; ++i) {
            indexes[i] = params[i].indexes;
            recipients[i] = params[i].recipients;
            amounts[i] = params[i].amounts;
        }

        uint256[] memory actualLeaves = new uint256[](count);
        actualLeaves = MerkleBuilder.computeLeavesLL(indexes, recipients, amounts);

        uint256[] memory expectedLeaves = new uint256[](count);
        for (uint256 i = 0; i < count; ++i) {
            expectedLeaves[i] =
                uint256(keccak256(bytes.concat(keccak256(abi.encode(indexes[i], recipients[i], amounts[i])))));
        }

        assertEq(actualLeaves, expectedLeaves, "computeLeavesLL");
    }
}
