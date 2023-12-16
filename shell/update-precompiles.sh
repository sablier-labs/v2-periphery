#!/usr/bin/env bash

# Pre-requisites:
# - foundry (https://getfoundry.sh)
# - jq (https://stedolan.github.io/jq)
# - sd (https://github.com/chmln/sd)

# Strict mode: https://gist.github.com/vncsna/64825d5609c146e80de8b1fd623011ca
set -euo pipefail

# Compile the contracts with Forge
FOUNDRY_PROFILE=optimized forge build

# Retrieve the raw bytecodes, removing the "0x" prefix
batch=$(cat out-optimized/SablierV2Batch.sol/SablierV2Batch.json | jq -r '.bytecode.object' | cut -c 3-)
merkle_streamer_factory=$(cat out-optimized/SablierV2MerkleStreamerFactory.sol/SablierV2MerkleStreamerFactory.json | jq -r '.bytecode.object' | cut -c 3-)

precompiles_path="test/utils/Precompiles.sol"
if [ ! -f $precompiles_path ]; then
    echo "Precompiles file does not exist"
    exit 1
fi

# Replace the current bytecodes
sd "(BYTECODE_BATCH =)[^;]+;" "\$1 hex\"$batch\";" $precompiles_path
sd "(BYTECODE_MERKLE_STREAMER_FACTORY =)[^;]+;" "\$1 hex\"$merkle_streamer_factory\";" $precompiles_path

# Reformat the code with Forge
forge fmt $precompiles_path
