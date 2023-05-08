// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { Errors } from "../libraries/Errors.sol";

/// @title NoStandardCall
/// @notice This contract implements logic to prevent standard calls, i.e. allow only delegate calls.
abstract contract NoStandardCall {
    /*//////////////////////////////////////////////////////////////////////////
                                  INTERNAL STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev The address of the original contract that was deployed.
    address private immutable _original;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Sets the original contract address.
    constructor() {
        _original = address(this);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Prevents standard calls.
    modifier noStandardCall() {
        _preventStandardCall();
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                            INTERNAL CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev This function checks whether a standard call is being made.
    ///
    /// - A private function is used instead of inlining this logic in a modifier because Solidity copies modifiers into
    /// every function that uses them. The `_original` address would get copied in every place the modifier is used,
    /// which would increase the contract size. By using a function instead, we can avoid this duplication of code
    /// and reduce the overall size of the contract.
    function _preventStandardCall() private view {
        if (address(this) == _original) {
            revert Errors.StandardCall();
        }
    }
}
