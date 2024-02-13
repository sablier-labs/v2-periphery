// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

library ArrayBuilder {
    /// @notice Generates an ordered array of integers which starts at `firstStreamId` and ends at `firstStreamId +
    /// batchSize - 1`.
    function fillStreamIds(
        uint256 firstStreamId,
        uint256 batchSize
    )
        internal
        pure
        returns (uint256[] memory streamIds)
    {
        streamIds = new uint256[](batchSize);
        for (uint256 i = 0; i < batchSize; ++i) {
            unchecked {
                streamIds[i] = firstStreamId + i;
            }
        }
    }
}
