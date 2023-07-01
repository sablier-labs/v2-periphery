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
archive=$(cat out-optimized/SablierV2Archive.sol/SablierV2Archive.json | jq -r '.bytecode.object' | cut -c 3-)
proxy_plugin=$(cat out-optimized/SablierV2ProxyPlugin.sol/SablierV2ProxyPlugin.json | jq -r '.bytecode.object' | cut -c 3-)
proxy_target=$(cat out-optimized/SablierV2ProxyTarget.sol/SablierV2ProxyTarget.json | jq -r '.bytecode.object' | cut -c 3-)

precompiles_path="test/utils/Precompiles.sol"
if [ ! -f $precompiles_path ]; then
    echo "Precompiles file does not exist"
    exit 1
fi

# Replace the current bytecodes
sd "(BYTECODE_ARCHIVE =)[^;]+;" "\$1 hex\"$archive\";" $precompiles_path
sd "(BYTECODE_PROXY_PLUGIN =)[^;]+;" "\$1 hex\"$proxy_plugin\";" $precompiles_path
sd "(BYTECODE_PROXY_TARGET =)[^;]+;" "\$1 hex\"$proxy_target\";" $precompiles_path

# Reformat the code with Forge
forge fmt $precompiles_path
