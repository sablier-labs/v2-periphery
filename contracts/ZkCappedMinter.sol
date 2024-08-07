// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/// @dev https://github.com/ZKsync-Association/zk-governance
interface IMintable {
    function mint(address _to, uint256 _amount) external;
}

/// @dev https://github.com/ZKsync-Association/zk-governance
interface IMintableAndDelegatable is IMintable {
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function delegateOnBehalf(
        address _signer,
        address _delegatee,
        uint256 _expiry,
        bytes calldata _signature
    )
        external;
    function delegates(address _account) external view returns (address);
}

/// @title ZkCappedMinter
/// @dev https://github.com/ZKsync-Association/zk-governance
/// @custom:security-contact security@zksync.io
contract ZkCappedMinter {
    /// @notice The contract where the tokens will be minted by an authorized minter.
    IMintableAndDelegatable public immutable TOKEN;

    /// @notice The address that is allowed to mint tokens.
    address public immutable ADMIN;

    /// @notice The maximum number of tokens that may be minted by the ZkCappedMinter.
    uint256 public immutable CAP;

    /// @notice The cumulative number of tokens that have been minted by the ZkCappedMinter.
    uint256 public minted = 0;

    /// @notice Error for when the cap is exceeded.
    error ZkCappedMinter__CapExceeded(address minter, uint256 amount);

    /// @notice Error for when the caller is not the admin.
    error ZkCappedMinter__Unauthorized(address account);

    /// @notice Constructor for a new ZkCappedMinter contract
    /// @param _token The token contract where tokens will be minted.
    /// @param _admin The address that is allowed to mint tokens.
    /// @param _cap The maximum number of tokens that may be minted by the ZkCappedMinter.
    constructor(IMintableAndDelegatable _token, address _admin, uint256 _cap) {
        TOKEN = _token;
        ADMIN = _admin;
        CAP = _cap;
    }

    /// @notice Mints a given amount of tokens to a given address, so long as the cap is not exceeded.
    /// @param _to The address that will receive the new tokens.
    /// @param _amount The quantity of tokens, in raw decimals, that will be created.
    function mint(address _to, uint256 _amount) external {
        _revertIfUnauthorized();
        _revertIfCapExceeded(_amount);
        minted += _amount;
        TOKEN.mint(_to, _amount);
    }

    /// @notice Reverts if msg.sender is not the contract admin.
    function _revertIfUnauthorized() internal view {
        if (msg.sender != ADMIN) {
            revert ZkCappedMinter__Unauthorized(msg.sender);
        }
    }

    /// @notice Reverts if the amount of new tokens will increase the minted tokens beyond the mint cap.
    /// @param _amount The quantity of tokens, in raw decimals, that will checked against the cap.
    function _revertIfCapExceeded(uint256 _amount) internal view {
        if (minted + _amount > CAP) {
            revert ZkCappedMinter__CapExceeded(msg.sender, _amount);
        }
    }
}
