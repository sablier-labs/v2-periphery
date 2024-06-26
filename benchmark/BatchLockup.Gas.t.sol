// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { ud2x18 } from "@prb/math/src/UD2x18.sol";
import { LockupDynamic, LockupLinear, LockupTranched } from "@sablier/v2-core/src/types/DataTypes.sol";

import { BatchLockup } from "../src/types/DataTypes.sol";
import { BatchLockupBuilder } from "../test/utils/BatchLockupBuilder.sol";
import { Benchmark_Test } from "./Benchmark.t.sol";

/// @notice Tests used to benchmark BatchLockup.
/// @dev This contract creates a Markdown file with the gas usage of each function.
contract BatchLockup_Gas_Test is Benchmark_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    uint128 internal constant AMOUNT_PER_LD_STREAM = AMOUNT_PER_SEGMENT * SEGMENTS_PER_STREAM;
    uint128 internal constant AMOUNT_PER_LT_STREAM = AMOUNT_PER_TRANCHE * TRANCHES_PER_STREAM;
    uint128 internal constant AMOUNT_PER_SEGMENT = 10e18;
    uint128 internal constant AMOUNT_PER_TRANCHE = 10e18;
    uint128 internal constant SEGMENTS_PER_STREAM = 5;
    uint128 internal constant TRANCHES_PER_STREAM = 5;

    uint8[5] internal batchSize = [2, 5, 10, 20, 50];

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function testGas_Implementations() external {
        // Set the file path.
        benchmarkResultsFile = string.concat(benchmarkResults, "SablierV2BatchLockup.md");

        // Create the file if it doesn't exist, otherwise overwrite it.
        vm.writeFile({
            path: benchmarkResultsFile,
            data: string.concat(
                "# Benchmarks for BatchLockup\n\n",
                "| Function | Lockup Type | Segments/Tranches | Batch Size | Gas Usage |\n",
                "| --- | --- | --- | --- | --- |\n"
            )
        });

        for (uint256 i; i < batchSize.length; ++i) {
            // Gas benchmark the batch create functions for Lockup Linear.
            gasCreateWithDurationsLL(batchSize[i]);
            gasCreateWithTimestampsLL(batchSize[i]);

            // Gas benchmark the batch create functions for Lockup Dynamic.
            gasCreateWithDurationsLD(batchSize[i]);
            gasCreateWithTimestampsLD(batchSize[i]);

            // Gas benchmark the batch create functions for Lockup Tranched.
            gasCreateWithDurationsLT(batchSize[i]);
            gasCreateWithTimestampsLT(batchSize[i]);
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                        GAS BENCHMARKS FOR BATCH FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function gasCreateWithDurationsLD(uint256 batchsize) internal {
        BatchLockup.CreateWithDurationsLD[] memory params = BatchLockupBuilder.fillBatch(
            defaults.createWithDurationsLD(dai, AMOUNT_PER_LD_STREAM, _segmentsWithDuration()), batchsize
        );

        uint256 beforeGas = gasleft();
        batchLockup.createWithDurationsLD(lockupDynamic, dai, params);
        string memory gasUsed = vm.toString(beforeGas - gasleft());

        contentToAppend = string.concat(
            "| `createWithDurationsLD` | Lockup Dynamic |",
            vm.toString(SEGMENTS_PER_STREAM),
            " |",
            vm.toString(batchsize),
            " | ",
            gasUsed,
            " |"
        );

        // Append the content to the file.
        appendToFile(benchmarkResultsFile, contentToAppend);
    }

    function gasCreateWithTimestampsLD(uint256 batchsize) internal {
        BatchLockup.CreateWithTimestampsLD[] memory params = BatchLockupBuilder.fillBatch(
            defaults.createWithTimestampsLD(dai, AMOUNT_PER_LD_STREAM, _segments()), batchsize
        );

        uint256 beforeGas = gasleft();
        batchLockup.createWithTimestampsLD(lockupDynamic, dai, params);
        string memory gasUsed = vm.toString(beforeGas - gasleft());

        contentToAppend = string.concat(
            "| `createWithTimestampsLD` | Lockup Dynamic |",
            vm.toString(SEGMENTS_PER_STREAM),
            " |",
            vm.toString(batchsize),
            " | ",
            gasUsed,
            " |"
        );

        // Append the data to the file
        appendToFile(benchmarkResultsFile, contentToAppend);
    }

    function gasCreateWithDurationsLL(uint256 batchsize) internal {
        BatchLockup.CreateWithDurationsLL[] memory params =
            BatchLockupBuilder.fillBatch(defaults.createWithDurationsLL(dai), batchsize);

        uint256 beforeGas = gasleft();
        batchLockup.createWithDurationsLL(lockupLinear, dai, params);
        string memory gasUsed = vm.toString(beforeGas - gasleft());

        contentToAppend = string.concat(
            "| `createWithDurationsLL` | Lockup Linear |  |", vm.toString(batchsize), " | ", gasUsed, " |"
        );

        // Append the content to the file.
        appendToFile(benchmarkResultsFile, contentToAppend);
    }

    function gasCreateWithTimestampsLL(uint256 batchsize) internal {
        BatchLockup.CreateWithTimestampsLL[] memory params =
            BatchLockupBuilder.fillBatch(defaults.createWithTimestampsLL(dai), batchsize);

        uint256 beforeGas = gasleft();
        batchLockup.createWithTimestampsLL(lockupLinear, dai, params);
        string memory gasUsed = vm.toString(beforeGas - gasleft());

        contentToAppend = string.concat(
            "| `createWithTimestampsLL` | Lockup Linear |  |", vm.toString(batchsize), " | ", gasUsed, " |"
        );

        // Append the data to the file
        appendToFile(benchmarkResultsFile, contentToAppend);
    }

    function gasCreateWithDurationsLT(uint256 batchsize) internal {
        BatchLockup.CreateWithDurationsLT[] memory params = BatchLockupBuilder.fillBatch(
            defaults.createWithDurationsLT(dai, AMOUNT_PER_LT_STREAM, _tranchesWithDuration()), batchsize
        );

        uint256 beforeGas = gasleft();
        batchLockup.createWithDurationsLT(lockupTranched, dai, params);
        string memory gasUsed = vm.toString(beforeGas - gasleft());

        contentToAppend = string.concat(
            "| `createWithDurationsLT` | Lockup Tranched |",
            vm.toString(TRANCHES_PER_STREAM),
            " |",
            vm.toString(batchsize),
            " | ",
            gasUsed,
            " |"
        );

        // Append the content to the file.
        appendToFile(benchmarkResultsFile, contentToAppend);
    }

    function gasCreateWithTimestampsLT(uint256 batchsize) internal {
        BatchLockup.CreateWithTimestampsLT[] memory params = BatchLockupBuilder.fillBatch(
            defaults.createWithTimestampsLT(dai, AMOUNT_PER_LT_STREAM, _tranches()), batchsize
        );

        uint256 beforeGas = gasleft();
        batchLockup.createWithTimestampsLT(lockupTranched, dai, params);
        string memory gasUsed = vm.toString(beforeGas - gasleft());

        contentToAppend = string.concat(
            "| `createWithTimestampsLT` | Lockup Tranched |",
            vm.toString(TRANCHES_PER_STREAM),
            " |",
            vm.toString(batchsize),
            " | ",
            gasUsed,
            " |"
        );

        // Append the data to the file
        appendToFile(benchmarkResultsFile, contentToAppend);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _segments() private view returns (LockupDynamic.Segment[] memory) {
        LockupDynamic.Segment[] memory segments = new LockupDynamic.Segment[](SEGMENTS_PER_STREAM);

        // Populate segments.
        for (uint256 i = 0; i < SEGMENTS_PER_STREAM; ++i) {
            segments[i] = LockupDynamic.Segment({
                amount: AMOUNT_PER_SEGMENT,
                exponent: ud2x18(0.5e18),
                timestamp: getBlockTimestamp() + uint40(defaults.CLIFF_DURATION() * (1 + i))
            });
        }

        return segments;
    }

    function _segmentsWithDuration() private view returns (LockupDynamic.SegmentWithDuration[] memory) {
        LockupDynamic.SegmentWithDuration[] memory segments =
            new LockupDynamic.SegmentWithDuration[](SEGMENTS_PER_STREAM);

        // Populate segments.
        for (uint256 i; i < SEGMENTS_PER_STREAM; ++i) {
            segments[i] = LockupDynamic.SegmentWithDuration({
                amount: AMOUNT_PER_SEGMENT,
                exponent: ud2x18(0.5e18),
                duration: defaults.CLIFF_DURATION()
            });
        }

        return segments;
    }

    function _tranches() private view returns (LockupTranched.Tranche[] memory) {
        LockupTranched.Tranche[] memory tranches = new LockupTranched.Tranche[](TRANCHES_PER_STREAM);
        // Populate tranches.
        for (uint256 i = 0; i < TRANCHES_PER_STREAM; ++i) {
            tranches[i] = (
                LockupTranched.Tranche({
                    amount: AMOUNT_PER_TRANCHE,
                    timestamp: getBlockTimestamp() + uint40(defaults.CLIFF_DURATION() * (1 + i))
                })
            );
        }

        return tranches;
    }

    function _tranchesWithDuration() private view returns (LockupTranched.TrancheWithDuration[] memory) {
        LockupTranched.TrancheWithDuration[] memory tranches =
            new LockupTranched.TrancheWithDuration[](TRANCHES_PER_STREAM);

        // Populate tranches.
        for (uint256 i; i < TRANCHES_PER_STREAM; ++i) {
            tranches[i] =
                LockupTranched.TrancheWithDuration({ amount: AMOUNT_PER_TRANCHE, duration: defaults.CLIFF_DURATION() });
        }

        return tranches;
    }
}
