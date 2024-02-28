// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ISablierV2Lockup } from "@sablier/v2-core/src/interfaces/ISablierV2Lockup.sol";
import { Broker, LockupDynamic, LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { UD2x18 } from "@prb/math/src/UD2x18.sol";

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

library MerkleLockup {
    /// @notice Struct encapsulating the base constructor parameter of a {SablierV2MerkleLockup} contract.
    /// @param initialAdmin The initial admin of the Merkle Lockup contract.
    /// @param asset The address of the streamed ERC-20 asset.
    /// @param ipfsCID The content identifier for indexing the contract on IPFS.
    /// @param name The name of the campaign.
    /// @param merkleRoot The Merkle root of the claim data.
    /// @param expiration The expiration of the streaming campaign, as a Unix timestamp.
    /// @param cancelable Indicates if each stream will be cancelable.
    /// @param transferable Indicates if each stream NFT will be transferable.
    struct ConstructorParams {
        address initialAdmin;
        IERC20 asset;
        string ipfsCID;
        string name;
        bytes32 merkleRoot;
        uint40 expiration;
        bool cancelable;
        bool transferable;
    }
}

library MerkleLockupLT {
    /// @notice Struct encapsulating the amount percentage and the tranche duration of the stream.
    /// @dev Each recipient may have a different amount allocated, this struct stores the percentage of the
    /// amount designated for each duration unlock. We use a 18 decimals format to represent percentages:
    /// 100% = 1e18.
    /// @param amountPercentage The percentage of the amount designated to be unlocked in this tranche.
    /// @param duration The time difference in seconds between this tranche and the previous one.
    struct TrancheWithPercentage {
        // slot 0
        UD2x18 amountPercentage;
        uint40 duration;
    }
}
