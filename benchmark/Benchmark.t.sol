// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { Integration_Test } from "../test/integration/Integration.t.sol";

/// @notice Benchmark contract with common logic needed by all tests.
abstract contract Benchmark_Test is Integration_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev The directory where the benchmark files are stored.
    string internal benchmarkResults = "benchmark/results/";

    /// @dev The path to the file where the benchmark results are stored.
    string internal benchmarkResultsFile;

    /// @dev A variable used to store the content to append to the results file.
    string internal contentToAppend;

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public override {
        super.setUp();

        deal({ token: address(dai), to: users.alice, give: type(uint256).max });
        resetPrank({ msgSender: users.alice });

        // Create the first streams in each Lockup contract to initialize all the variables.
        _createFewStreams();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Append a line to the file at given path.
    function appendToFile(string memory path, string memory line) internal {
        vm.writeLine({ path: path, data: line });
    }

    /// @dev Internal function to creates a few streams in each Lockup contract.
    function _createFewStreams() private {
        approveContract({ asset_: dai, from: users.alice, spender: address(lockupDynamic) });
        approveContract({ asset_: dai, from: users.alice, spender: address(lockupLinear) });
        approveContract({ asset_: dai, from: users.alice, spender: address(lockupTranched) });
        for (uint128 i = 0; i < 100; ++i) {
            lockupDynamic.createWithTimestamps(defaults.createWithTimestampsLD());
            lockupLinear.createWithTimestamps(defaults.createWithTimestampsLL());
            lockupTranched.createWithTimestamps(defaults.createWithTimestampsLT());
        }
    }
}
