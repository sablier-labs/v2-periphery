// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Adminable } from "@sablier/v2-core/src/abstracts/Adminable.sol";
import { ISablierV2LockupDynamic } from "@sablier/v2-core/src/interfaces/ISablierV2LockupDynamic.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { ISablierV2LockupTranched } from "@sablier/v2-core/src/interfaces/ISablierV2LockupTranched.sol";

import { ISablierV2BatchLockup } from "./interfaces/ISablierV2BatchLockup.sol";
import { BatchLockup } from "./types/DataTypes.sol";

/// @dev https://github.com/ZKsync-Association/zk-governance
interface IMintable {
    function mint(address _to, uint256 _amount) external;
}

/// @title ZkNationSablierGateway
/// @notice This contract is a gateway for minting ZK tokens and creating Sablier streams.
/// @dev The functions in this contract are expected to ONLY be used by the Token Governor Timelock contract.
contract ZkNationSablierGateway is Adminable {
    /*//////////////////////////////////////////////////////////////////////////
                                EVENTS AND ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    event UpdateZkTokenMinter(address oldZkMinter, address newZkMinter);

    error ZkNationSablierGateway_TransferAmountZero();

    error ZkNationSablierGateway_Unauthorized(address caller);

    /*//////////////////////////////////////////////////////////////////////////
                                 STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev The address of the Sablier batch lockup contract.
    ISablierV2BatchLockup public immutable SABLIER_BATCH_LOCKUP;

    /// @dev The address of the ZK token contract.
    IERC20 public immutable ZK_TOKEN;

    /// @dev The address of the Token Governor Timelock contract.
    address public immutable ZK_TOKEN_TIMELOCK;

    /// @dev The address of the ZkCappedMinter contract.
    IMintable public zkCappedMinter;

    /*//////////////////////////////////////////////////////////////////////////
                                    MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Throws if the caller is not Token Governor Timelock contract.
    modifier onlyZkTokenTimelock() {
        if (msg.sender != ZK_TOKEN_TIMELOCK) {
            revert ZkNationSablierGateway_Unauthorized(msg.sender);
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Emits a {TransferAdmin} event.
    /// @param initialAdmin The address of the initial contract admin.
    /// @param batchLockup The address of the Sablier batch lockup contract.
    /// @param zkToken The address of the ZK token contract.
    /// @param zkTokenTimelock The address of the Token Governor Timelock contract.
    constructor(address initialAdmin, ISablierV2BatchLockup batchLockup, IERC20 zkToken, address zkTokenTimelock) {
        admin = initialAdmin;
        SABLIER_BATCH_LOCKUP = batchLockup;
        ZK_TOKEN = zkToken;
        ZK_TOKEN_TIMELOCK = zkTokenTimelock;

        emit TransferAdmin({ oldAdmin: address(0), newAdmin: initialAdmin });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                 ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Sets the ZkCappedMinter contract address.
    /// @dev Call this function after deploying the ZkCappedMinter and ZKNationSablierGateway contracts.
    function setZkTokenMinter(IMintable tokenMinter) external onlyAdmin {
        IMintable oldMinter = zkCappedMinter;

        // Set the new ZkCappedMinter contract address.
        zkCappedMinter = tokenMinter;

        emit UpdateZkTokenMinter({ oldZkMinter: address(oldMinter), newZkMinter: address(tokenMinter) });
    }

    /*//////////////////////////////////////////////////////////////////////////
                              BATCH LOCKUP FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Mints ZK tokens and creates Sablier Lockup Dynamic streams with durations.
    /// @dev msg.sender MUST be the Token Governor Timelock contract.
    ///   - docs:
    /// https://docs.sablier.com/contracts/v2/reference/periphery/contract.SablierV2BatchLockup#createwithdurationsld
    function mintAndCreateWithDurationsLD(
        ISablierV2LockupDynamic lockupDynamic,
        BatchLockup.CreateWithDurationsLD[] calldata batch
    )
        external
        onlyZkTokenTimelock
        returns (uint256[] memory streamIds)
    {
        // Calculate the sum of all of stream amounts.
        uint256 transferAmount;
        for (uint256 i = 0; i < batch.length; ++i) {
            transferAmount += batch[i].totalAmount;
        }

        // Mint ZK tokens to this contract and approve Batch lockup to handle transfer.
        _mintAndApprove(transferAmount);

        // Create Sablier streams.
        streamIds = SABLIER_BATCH_LOCKUP.createWithDurationsLD(lockupDynamic, ZK_TOKEN, batch);
    }

    /// @notice Mints ZK tokens and creates Sablier Lockup Dynamic streams with timestamps.
    /// @dev msg.sender MUST be the Token Governor Timelock contract.
    ///   - docs:
    /// https://docs.sablier.com/contracts/v2/reference/periphery/contract.SablierV2BatchLockup#createwithtimestampsld
    function mintAndCreateWithTimestampsLD(
        ISablierV2LockupDynamic lockupDynamic,
        BatchLockup.CreateWithTimestampsLD[] calldata batch
    )
        external
        onlyZkTokenTimelock
        returns (uint256[] memory streamIds)
    {
        // Calculate the sum of all of stream amounts.
        uint256 transferAmount;
        for (uint256 i = 0; i < batch.length; ++i) {
            transferAmount += batch[i].totalAmount;
        }

        // Mint ZK tokens to this contract and approve Batch lockup to handle transfer.
        _mintAndApprove(transferAmount);

        // Create Sablier streams.
        streamIds = SABLIER_BATCH_LOCKUP.createWithTimestampsLD(lockupDynamic, ZK_TOKEN, batch);
    }

    /// @notice Mints ZK tokens and creates Sablier Lockup Linear streams with durations.
    /// @dev msg.sender MUST be the Token Governor Timelock contract.
    ///   - docs:
    /// https://docs.sablier.com/contracts/v2/reference/periphery/contract.SablierV2BatchLockup#createwithdurationsll
    function mintAndCreateWithDurationsLL(
        ISablierV2LockupLinear lockupLinear,
        BatchLockup.CreateWithDurationsLL[] calldata batch
    )
        external
        onlyZkTokenTimelock
        returns (uint256[] memory streamIds)
    {
        // Calculate the sum of all of stream amounts.
        uint256 transferAmount;
        for (uint256 i = 0; i < batch.length; ++i) {
            transferAmount += batch[i].totalAmount;
        }

        // Mint ZK tokens to this contract and approve Batch lockup to handle transfer.
        _mintAndApprove(transferAmount);

        // Create Sablier streams.
        streamIds = SABLIER_BATCH_LOCKUP.createWithDurationsLL(lockupLinear, ZK_TOKEN, batch);
    }

    /// @notice Mints ZK tokens and creates Sablier Lockup Linear streams with timestamps.
    /// @dev msg.sender MUST be the Token Governor Timelock contract.
    ///   - docs:
    /// https://docs.sablier.com/contracts/v2/reference/periphery/contract.SablierV2BatchLockup#createwithtimestampsll
    function mintAndCreateWithTimestampsLL(
        ISablierV2LockupLinear lockupLinear,
        BatchLockup.CreateWithTimestampsLL[] calldata batch
    )
        external
        onlyZkTokenTimelock
        returns (uint256[] memory streamIds)
    {
        // Calculate the sum of all of stream amounts.
        uint256 transferAmount;
        for (uint256 i = 0; i < batch.length; ++i) {
            transferAmount += batch[i].totalAmount;
        }

        // Mint ZK tokens to this contract and approve Batch lockup to handle transfer.
        _mintAndApprove(transferAmount);

        // Create Sablier streams.
        streamIds = SABLIER_BATCH_LOCKUP.createWithTimestampsLL(lockupLinear, ZK_TOKEN, batch);
    }

    /// @notice Mints ZK tokens and creates Sablier Lockup Tranched streams with durations.
    /// @dev msg.sender MUST be the Token Governor Timelock contract.
    ///   - docs:
    /// https://docs.sablier.com/contracts/v2/reference/periphery/contract.SablierV2BatchLockup#createwithdurationslt
    function mintAndCreateWithDurationsLT(
        ISablierV2LockupTranched lockupTranched,
        BatchLockup.CreateWithDurationsLT[] calldata batch
    )
        external
        onlyZkTokenTimelock
        returns (uint256[] memory streamIds)
    {
        // Calculate the sum of all of stream amounts.
        uint256 transferAmount;
        for (uint256 i = 0; i < batch.length; ++i) {
            transferAmount += batch[i].totalAmount;
        }

        // Mint ZK tokens to this contract and approve Batch lockup to handle transfer.
        _mintAndApprove(transferAmount);

        // Create Sablier streams.
        streamIds = SABLIER_BATCH_LOCKUP.createWithDurationsLT(lockupTranched, ZK_TOKEN, batch);
    }

    /// @notice Mints ZK tokens and creates Sablier Lockup Tranched streams with timestamps.
    /// @dev msg.sender MUST be the Token Governor Timelock contract.
    ///   - docs:
    /// https://docs.sablier.com/contracts/v2/reference/periphery/contract.SablierV2BatchLockup#createwithtimestampslt
    function mintAndCreateWithTimestampsLT(
        ISablierV2LockupTranched lockupTranched,
        BatchLockup.CreateWithTimestampsLT[] calldata batch
    )
        external
        onlyZkTokenTimelock
        returns (uint256[] memory streamIds)
    {
        // Calculate the sum of all of stream amounts.
        uint256 transferAmount;
        for (uint256 i = 0; i < batch.length; ++i) {
            transferAmount += batch[i].totalAmount;
        }

        // Mint ZK tokens to this contract and approve Batch lockup to handle transfer.
        _mintAndApprove(transferAmount);

        // Create Sablier streams.
        streamIds = SABLIER_BATCH_LOCKUP.createWithTimestampsLT(lockupTranched, ZK_TOKEN, batch);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  HELPER FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function _mintAndApprove(uint256 transferAmount) private {
        // Check that the transfer amount is not zero.
        if (transferAmount == 0) {
            revert ZkNationSablierGateway_TransferAmountZero();
        }

        // Mint ZK tokens to this contract.
        IMintable(zkCappedMinter).mint(address(this), transferAmount);

        // Approve the Sablier contract to transfer the ZK tokens.
        ZK_TOKEN.approve({ spender: address(SABLIER_BATCH_LOCKUP), value: transferAmount });
    }
}
