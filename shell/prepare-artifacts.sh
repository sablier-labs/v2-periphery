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
  "$artifacts/libraries"

# Generate the artifacts with Forge
FOUNDRY_PROFILE=optimized forge build

# Copy the production artifacts
cp out-optimized/SablierV2Batch.sol/SablierV2Batch.json $artifacts
cp out-optimized/SablierV2MerkleStreamerFactory.sol/SablierV2MerkleStreamerFactory.json $artifacts
cp out-optimized/SablierV2MerkleStreamerLL.sol/SablierV2MerkleStreamerLL.json $artifacts

interfaces=./artifacts/interfaces
cp out-optimized/ISablierV2Batch.sol/ISablierV2Batch.json $interfaces
cp out-optimized/ISablierV2MerkleStreamerFactory.sol/ISablierV2MerkleStreamerFactory.json $interfaces
cp out-optimized/ISablierV2MerkleStreamerLL.sol/ISablierV2MerkleStreamerLL.json $interfaces

erc20=./artifacts/interfaces/erc20
cp out-optimized/IERC20.sol/IERC20.json $erc20

libraries=./artifacts/libraries
cp out-optimized/Errors.sol/Errors.json $libraries

# Format the artifacts with Prettier
pnpm prettier --write ./artifacts
