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
cp optimized-out/SablierV2Archive.sol/SablierV2Archive.json $artifacts
cp optimized-out/SablierV2ProxyPlugin.sol/SablierV2ProxyPlugin.json $artifacts
cp optimized-out/SablierV2ProxyTarget.sol/SablierV2ProxyTarget.json $artifacts

interfaces=./artifacts/interfaces
cp optimized-out/ISablierV2Archive.sol/ISablierV2Archive.json $interfaces
cp optimized-out/ISablierV2ProxyPlugin.sol/ISablierV2ProxyPlugin.json $interfaces
cp optimized-out/ISablierV2ProxyTarget.sol/ISablierV2ProxyTarget.json $interfaces

erc20=./artifacts/interfaces/erc20
cp optimized-out/IERC20.sol/IERC20.json $erc20
cp optimized-out/IWrappedNativeAsset.sol/IWrappedNativeAsset.json $erc20

permit2=./artifacts/interfaces/permit2
cp optimized-out/IAllowanceTransfer.sol/IAllowanceTransfer.json $permit2

libraries=./artifacts/libraries
cp optimized-out/Errors.sol/Errors.json $libraries

# Format the artifacts with Prettier
pnpm prettier --write ./artifacts
