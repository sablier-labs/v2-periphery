#!/usr/bin/env bash

# Notes:
# - The script must be run from the repo's root directory

# Pre-requisites:
# - foundry (https://getfoundry.sh)
# - pnpm (https://pnpm.io)

# Strict mode: https://gist.github.com/vncsna/64825d5609c146e80de8b1fd623011ca
set -euo pipefail

# Delete the current artifacts
artifacts=./artifacts
rm -rf $artifacts

# Create the new artifacts directories
mkdir $artifacts \
  "$artifacts/interfaces" \
  "$artifacts/interfaces/erc20" \
  "$artifacts/interfaces/permit2" \
  "$artifacts/libraries"

# Generate the artifacts with Forge
FOUNDRY_PROFILE=optimized forge build

# Copy the production artifacts
cp out-optimized/SablierV2Archive.sol/SablierV2Archive.json $artifacts
cp out-optimized/SablierV2ProxyPlugin.sol/SablierV2ProxyPlugin.json $artifacts
cp out-optimized/SablierV2ProxyTargetApprove.sol/SablierV2ProxyTargetApprove.json $artifacts
cp out-optimized/SablierV2ProxyTargetPermit2.sol/SablierV2ProxyTargetPermit2.json $artifacts
cp out-optimized/SablierV2ProxyTargetPush.sol/SablierV2ProxyTargetPush.json $artifacts

interfaces=./artifacts/interfaces
cp out-optimized/ISablierV2Archive.sol/ISablierV2Archive.json $interfaces
cp out-optimized/ISablierV2ProxyPlugin.sol/ISablierV2ProxyPlugin.json $interfaces
cp out-optimized/ISablierV2ProxyTarget.sol/ISablierV2ProxyTarget.json $interfaces

erc20=./artifacts/interfaces/erc20
cp out-optimized/IERC20.sol/IERC20.json $erc20
cp out-optimized/IWrappedNativeAsset.sol/IWrappedNativeAsset.json $erc20

permit2=./artifacts/interfaces/permit2
cp out-optimized/IAllowanceTransfer.sol/IAllowanceTransfer.json $permit2

libraries=./artifacts/libraries
cp out-optimized/Errors.sol/Errors.json $libraries

# Format the artifacts with Prettier
pnpm prettier --write ./artifacts
