// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { BitMaps } from "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ud, UD60x18 } from "@prb/math/src/UD60x18.sol";
import { ISablierV2LockupTranched } from "@sablier/v2-core/src/interfaces/ISablierV2LockupTranched.sol";
import { Broker, LockupTranched } from "@sablier/v2-core/src/types/DataTypes.sol";

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

    /// @dev The tranches with their respective unlock percentages and durations.
    MerkleLockupLT.TrancheWithPercentage[] internal _tranchesWithPercentages;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Constructs the contract by initializing the immutable state variables, and max approving the Sablier
    /// contract.
    constructor(
        MerkleLockup.ConstructorParams memory baseParams,
        ISablierV2LockupTranched lockupTranched,
        MerkleLockupLT.TrancheWithPercentage[] memory tranchesWithPercentages
    )
        SablierV2MerkleLockup(baseParams)
    {
        LOCKUP_TRANCHED = lockupTranched;

        // Since Solidity lacks a syntax for copying arrays directly from memory to storage,
        // a manual approach is necessary. See https://github.com/ethereum/solidity/issues/12783.
        uint256 count = tranchesWithPercentages.length;
        for (uint256 i = 0; i < count; ++i) {
            _tranchesWithPercentages.push(tranchesWithPercentages[i]);
        }

        // Max approve the Sablier contract to spend funds from the Merkle Lockup contract.
        ASSET.forceApprove(address(LOCKUP_TRANCHED), type(uint256).max);
    }

    /*//////////////////////////////////////////////////////////////////////////
                           USER-FACING CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2MerkleLockupLT
    function getTranchesWithPercentages()
        external
        view
        override
        returns (MerkleLockupLT.TrancheWithPercentage[] memory)
    {
        return _tranchesWithPercentages;
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

        // Calculate the tranches based on the `amount`.
        LockupTranched.TrancheWithDuration[] memory tranches = _calculateTranches(amount);

        // Effects: mark the index as claimed.
        _claimedBitMap.set(index);

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

    /// @dev Calculates the tranches based on the Merkle tree amount and unlock percentage for each tranche.
    function _calculateTranches(uint128 amount)
        internal
        view
        returns (LockupTranched.TrancheWithDuration[] memory tranches)
    {
        // Load the tranches in memory to save gas.
        MerkleLockupLT.TrancheWithPercentage[] memory tranchesWithPercentages = _tranchesWithPercentages;

        // Declare the variables need for calculation.
        UD60x18 trancheAmountsSum;
        uint256 trancheCount = tranchesWithPercentages.length;
        tranches = new LockupTranched.TrancheWithDuration[](trancheCount);

        UD60x18 udAmount = ud(amount);

        // Iterate over each tranche to calculate its amount based on its percentage.
        for (uint256 i = 0; i < trancheCount; ++i) {
            // Convert the tranche's percentage to `UD60x18` for calculation.
            UD60x18 percentage = (tranchesWithPercentages[i].unlockPercentage).intoUD60x18();

            // Calculate the tranche's amount by applying its percentage to the `amount`.
            UD60x18 trancheAmount = udAmount.mul(percentage);

            // Sum all tranche amounts.
            trancheAmountsSum = trancheAmountsSum.add(trancheAmount);

            // Assign calculated amount and duration to the tranche.
            tranches[i] = LockupTranched.TrancheWithDuration({
                amount: trancheAmount.intoUint128(),
                duration: tranchesWithPercentages[i].duration
            });
        }

        // Adjust the last tranche amount to prevent claim failure due to rounding differences during calculations. We
        // need to ensure the core protocol invariant: the sum of all tranches' amounts equals the deposit amount.
        if (!udAmount.eq(trancheAmountsSum)) {
            tranches[trancheCount - 1].amount += udAmount.intoUint128() - trancheAmountsSum.intoUint128();
        }
    }
}
