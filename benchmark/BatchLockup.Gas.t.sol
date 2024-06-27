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

    uint128 internal constant AMOUNT_PER_COUNT = 10e18;
    uint8[5] internal batches = [5, 10, 20, 30, 50];
    uint8[5] internal counts = [24, 24, 24, 24, 12];

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

        for (uint256 i; i < batches.length; ++i) {
            // Gas benchmark the batch create functions for Lockup Linear.
            gasCreateWithDurationsLL(batches[i]);
            gasCreateWithTimestampsLL(batches[i]);

            // Gas benchmark the batch create functions for Lockup Dynamic.
            gasCreateWithDurationsLD({ batchsize: batches[i], segmentsCount: counts[i] });
            gasCreateWithTimestampsLD({ batchsize: batches[i], segmentsCount: counts[i] });

            // Gas benchmark the batch create functions for Lockup Tranched.
            gasCreateWithDurationsLT({ batchsize: batches[i], tranchesCount: counts[i] });
            gasCreateWithTimestampsLT({ batchsize: batches[i], tranchesCount: counts[i] });
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                        GAS BENCHMARKS FOR BATCH FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function gasCreateWithDurationsLD(uint256 batchsize, uint256 segmentsCount) internal {
        BatchLockup.CreateWithDurationsLD[] memory params = BatchLockupBuilder.fillBatch(
            defaults.createWithDurationsLD(
                dai, uint128(AMOUNT_PER_COUNT * segmentsCount), _segmentsWithDuration(segmentsCount)
            ),
            batchsize
        );

        uint256 beforeGas = gasleft();
        batchLockup.createWithDurationsLD(lockupDynamic, dai, params);
        string memory gasUsed = vm.toString(beforeGas - gasleft());

        contentToAppend = string.concat(
            "| `createWithDurationsLD` | Lockup Dynamic |",
            vm.toString(segmentsCount),
            " |",
            vm.toString(batchsize),
            " | ",
            gasUsed,
            " |"
        );

        // Append the content to the file.
        appendToFile(benchmarkResultsFile, contentToAppend);
    }

    function gasCreateWithTimestampsLD(uint256 batchsize, uint256 segmentsCount) internal {
        BatchLockup.CreateWithTimestampsLD[] memory params = BatchLockupBuilder.fillBatch(
            defaults.createWithTimestampsLD(dai, uint128(AMOUNT_PER_COUNT * segmentsCount), _segments(segmentsCount)),
            batchsize
        );

        uint256 beforeGas = gasleft();
        batchLockup.createWithTimestampsLD(lockupDynamic, dai, params);
        string memory gasUsed = vm.toString(beforeGas - gasleft());

        contentToAppend = string.concat(
            "| `createWithTimestampsLD` | Lockup Dynamic |",
            vm.toString(segmentsCount),
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

    function gasCreateWithDurationsLT(uint256 batchsize, uint256 tranchesCount) internal {
        BatchLockup.CreateWithDurationsLT[] memory params = BatchLockupBuilder.fillBatch(
            defaults.createWithDurationsLT(
                dai, uint128(AMOUNT_PER_COUNT * tranchesCount), _tranchesWithDuration(tranchesCount)
            ),
            batchsize
        );

        uint256 beforeGas = gasleft();
        batchLockup.createWithDurationsLT(lockupTranched, dai, params);
        string memory gasUsed = vm.toString(beforeGas - gasleft());

        contentToAppend = string.concat(
            "| `createWithDurationsLT` | Lockup Tranched |",
            vm.toString(tranchesCount),
            " |",
            vm.toString(batchsize),
            " | ",
            gasUsed,
            " |"
        );

        // Append the content to the file.
        appendToFile(benchmarkResultsFile, contentToAppend);
    }

    function gasCreateWithTimestampsLT(uint256 batchsize, uint256 tranchesCount) internal {
        BatchLockup.CreateWithTimestampsLT[] memory params = BatchLockupBuilder.fillBatch(
            defaults.createWithTimestampsLT(dai, uint128(AMOUNT_PER_COUNT * tranchesCount), _tranches(tranchesCount)),
            batchsize
        );

        uint256 beforeGas = gasleft();
        batchLockup.createWithTimestampsLT(lockupTranched, dai, params);
        string memory gasUsed = vm.toString(beforeGas - gasleft());

        contentToAppend = string.concat(
            "| `createWithTimestampsLT` | Lockup Tranched |",
            vm.toString(tranchesCount),
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

    function _segments(uint256 segmentsCount) private view returns (LockupDynamic.Segment[] memory) {
        LockupDynamic.Segment[] memory segments = new LockupDynamic.Segment[](segmentsCount);

        // Populate segments.
        for (uint256 i = 0; i < segmentsCount; ++i) {
            segments[i] = LockupDynamic.Segment({
                amount: AMOUNT_PER_COUNT,
                exponent: ud2x18(0.5e18),
                timestamp: getBlockTimestamp() + uint40(defaults.CLIFF_DURATION() * (1 + i))
            });
        }

        return segments;
    }

    function _segmentsWithDuration(uint256 segmentsCount)
        private
        view
        returns (LockupDynamic.SegmentWithDuration[] memory)
    {
        LockupDynamic.SegmentWithDuration[] memory segments = new LockupDynamic.SegmentWithDuration[](segmentsCount);

        // Populate segments.
        for (uint256 i; i < segmentsCount; ++i) {
            segments[i] = LockupDynamic.SegmentWithDuration({
                amount: AMOUNT_PER_COUNT,
                exponent: ud2x18(0.5e18),
                duration: defaults.CLIFF_DURATION()
            });
        }

        return segments;
    }

    function _tranches(uint256 tranchesCount) private view returns (LockupTranched.Tranche[] memory) {
        LockupTranched.Tranche[] memory tranches = new LockupTranched.Tranche[](tranchesCount);
        // Populate tranches.
        for (uint256 i = 0; i < tranchesCount; ++i) {
            tranches[i] = (
                LockupTranched.Tranche({
                    amount: AMOUNT_PER_COUNT,
                    timestamp: getBlockTimestamp() + uint40(defaults.CLIFF_DURATION() * (1 + i))
                })
            );
        }

        return tranches;
    }

    function _tranchesWithDuration(uint256 tranchesCount)
        private
        view
        returns (LockupTranched.TrancheWithDuration[] memory)
    {
        LockupTranched.TrancheWithDuration[] memory tranches = new LockupTranched.TrancheWithDuration[](tranchesCount);

        // Populate tranches.
        for (uint256 i; i < tranchesCount; ++i) {
            tranches[i] =
                LockupTranched.TrancheWithDuration({ amount: AMOUNT_PER_COUNT, duration: defaults.CLIFF_DURATION() });
        }

        return tranches;
    }
}
