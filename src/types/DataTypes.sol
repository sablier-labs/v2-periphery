// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ISablierV2Lockup } from "@sablier/v2-core/src/interfaces/ISablierV2Lockup.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { Broker, LockupDynamic, LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

library Batch {
    /// @notice A struct encapsulating the lockup contract's address and the stream ids to cancel.
    struct CancelMultiple {
        ISablierV2Lockup lockup;
        uint256[] streamIds;
    }

    /// @notice A struct encapsulating all parameters of {SablierV2LockupDynamic.createWithDurations} except for the
    /// asset.
    struct CreateWithDurationsLD {
        address sender;
        address recipient;
        uint128 totalAmount;
        bool cancelable;
        bool transferable;
        LockupDynamic.SegmentWithDuration[] segments;
        Broker broker;
    }

    /// @notice A struct encapsulating all parameters of {SablierV2LockupLinear.createWithDurations} except for the
    /// asset.
    struct CreateWithDurationsLL {
        address sender;
        address recipient;
        uint128 totalAmount;
        bool cancelable;
        bool transferable;
        LockupLinear.Durations durations;
        Broker broker;
    }

    /// @notice A struct encapsulating all parameters of {SablierV2LockupDynamic.createWithTimestamps} except for the
    /// asset.
    struct CreateWithTimestampsLD {
        address sender;
        address recipient;
        uint128 totalAmount;
        bool cancelable;
        bool transferable;
        uint40 startTime;
        LockupDynamic.Segment[] segments;
        Broker broker;
    }

    /// @notice A struct encapsulating all parameters of {SablierV2LockupLinear.createWithTimestamps} except for the
    /// asset.
    struct CreateWithTimestampsLL {
        address sender;
        address recipient;
        uint128 totalAmount;
        bool cancelable;
        bool transferable;
        LockupLinear.Range range;
        Broker broker;
    }
}

library MerkleStreamer {
    /// @notice Struct encapsulating the {SablierV2MerkleStreamerLL} parameters for the
    /// {SablierV2MerkleStreamerFactory.createMerkleStreamerLL}
    /// function.
    /// @param initialAdmin The initial admin of the Merkle streamer contract.
    /// @param lockupLinear The address of the {SablierV2LockupLinear} contract.
    /// @param asset The address of the streamed ERC-20 asset.
    /// @param name The name of the Merkle streamer contract.
    /// @param merkleRoot The Merkle root of the claim data.
    /// @param expiration The expiration of the streaming campaign, as a Unix timestamp.
    /// @param streamDurations The durations for each stream due to the recipient.
    /// @param cancelable Indicates if each stream will be cancelable.
    /// @param transferable Indicates if each stream NFT will be transferable.
    struct CreateWithLockupLinear {
        address initialAdmin;
        ISablierV2LockupLinear lockupLinear;
        IERC20 asset;
        string name;
        bytes32 merkleRoot;
        uint40 expiration;
        LockupLinear.Durations streamDurations;
        bool cancelable;
        bool transferable;
    }
}
