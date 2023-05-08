// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

/// @title Errors
/// @notice Library containing all custom errors the protocol may revert with.
library Errors {
    /*//////////////////////////////////////////////////////////////////////////
                                      GENERICS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when trying to perform a standard call to a function that allows only delegate calls.
    error StandardCall();

    /*//////////////////////////////////////////////////////////////////////////
                              SABLIER-V2-PROXY-PLUGIN
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when the caller is not Sablier.
    error SablierV2ProxyPlugin_CallerNotSablier(address caller);

    /*//////////////////////////////////////////////////////////////////////////
                              SABLIER-V2-PROXY-TARGET
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when trying to perform an action that requires the batch size to not be zero.
    error SablierV2ProxyTarget_BatchSizeZero();
}
