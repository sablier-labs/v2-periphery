// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { BitMaps } from "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ISablierV2LockupTranched } from "@sablier/v2-core/src/interfaces/ISablierV2LockupTranched.sol";
import { Broker, LockupTranched } from "@sablier/v2-core/src/types/DataTypes.sol";
import { ud, UD60x18 } from "@prb/math/src/UD60x18.sol";

import { SablierV2MerkleLockup } from "./abstracts/SablierV2MerkleLockup.sol";
import { ISablierV2MerkleLockupLT } from "./interfaces/ISablierV2MerkleLockupLT.sol";
import { MerkleLockup, MerkleLockupLT } from "./types/DataTypes.sol";

/// @title SablierV2MerkleLockupLT
/// @notice See the documentation in {ISablierV2MerkleLockupLT}.
contract SablierV2MerkleLockupLT is
    ISablierV2MerkleLockupLT, // 2 inherited components
    SablierV2MerkleLockup // 4 inherited components
{
    using BitMaps for BitMaps.BitMap;
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2MerkleLockupLT
    ISablierV2LockupTranched public immutable override LOCKUP_TRANCHED;

    /// @dev The tranches with their respective percentages and durations.
    MerkleLockupLT.TrancheWithPercentage[] internal _tranchesWithPercentage;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Constructs the contract by initializing the immutable state variables, and max approving the Sablier
    /// contract.
    constructor(
        MerkleLockup.ConstructorParams memory baseParams,
        ISablierV2LockupTranched lockupTranched,
        MerkleLockupLT.TrancheWithPercentage[] memory tranchesWithPercentage
    )
        SablierV2MerkleLockup(baseParams)
    {
        LOCKUP_TRANCHED = lockupTranched;
        _tranchesWithPercentage = tranchesWithPercentage;

        // Max approve the Sablier contract to spend funds from the Merkle Lockup contract.
        ASSET.forceApprove(address(LOCKUP_TRANCHED), type(uint256).max);
    }

    /*//////////////////////////////////////////////////////////////////////////
                           USER-FACING CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2MerkleLockupLT
    function getTranchesWithPercentage()
        external
        view
        override
        returns (MerkleLockupLT.TrancheWithPercentage[] memory)
    {
        return _tranchesWithPercentage;
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2MerkleLockupLT
    function claim(
        uint256 index,
        address recipient,
        uint128 amount,
        bytes32[] calldata merkleProof
    )
        external
        override
        returns (uint256 streamId)
    {
        // Generate the Merkle tree leaf by hashing the corresponding parameters. Hashing twice prevents second
        // preimage attacks.
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(index, recipient, amount))));

        // Checks: validate the function.
        _checkClaim(index, leaf, merkleProof);

        // Effects: mark the index as claimed.
        _claimedBitMap.set(index);

        // Calculate the tranches based on the amount.
        LockupTranched.TrancheWithDuration[] memory tranches = _calculateTranches(amount);

        // Interactions: create the stream via {SablierV2LockupTranched}.
        streamId = LOCKUP_TRANCHED.createWithDurations(
            LockupTranched.CreateWithDurations({
                sender: admin,
                recipient: recipient,
                totalAmount: amount,
                asset: ASSET,
                cancelable: CANCELABLE,
                transferable: TRANSFERABLE,
                tranches: tranches,
                broker: Broker({ account: address(0), fee: ud(0) })
            })
        );

        // Log the claim.
        emit Claim(index, recipient, amount, streamId);
    }

    /// @dev Calculates the stream tranches based on `amount` and predefined percentage for each tranche.
    function _calculateTranches(uint128 amount)
        internal
        view
        returns (LockupTranched.TrancheWithDuration[] memory tranches)
    {
        // Load the tranches in memory to save gas.
        MerkleLockupLT.TrancheWithPercentage[] memory tranchesWithPercentage = _tranchesWithPercentage;

        // Declare the variables needed for calculations.
        uint256 trancheCount = tranchesWithPercentage.length;
        UD60x18 udAmount = ud(amount);
        uint128 trancheAmountsSum = 0;

        tranches = new LockupTranched.TrancheWithDuration[](trancheCount);

        // Iterate over each tranche to calculate its amount based on its percentage.
        for (uint256 i = 0; i < trancheCount; ++i) {
            // Convert the tranche's percentage to `UD60x18` for calculation.
            UD60x18 percentage = (tranchesWithPercentage[i].amountPercentage).intoUD60x18();

            // Calculate the tranche's amount by applying its percentage to the total amount.
            uint128 trancheAmount = udAmount.mul(percentage).intoUint128();

            // Sum of all tranche amounts to handle any rounding errors.
            trancheAmountsSum += trancheAmount;

            // Assign calculated amount and duration to the tranche.
            tranches[i] = LockupTranched.TrancheWithDuration({
                amount: trancheAmount,
                duration: tranchesWithPercentage[i].duration
            });
        }

        // Adjust the last tranche amount in case of rounding differences during calculations.
        // This ensures the sum of tranche amounts equals the `amount`.
        if (trancheAmountsSum != amount) {
            tranches[trancheCount - 1].amount += amount - trancheAmountsSum;
        }
    }
}