#!/usr/bin/env bash

# Usage: ./shell/deploy-multi-chains.sh [options] [chain1 [chain2 ...]]
# Options:
#  --deterministic Deploy using the deterministic script.
#  --broadcast Broadcast the deployment and verify on Etherscan.
#  --with-gas-price Specify gas price for transaction.
#  --all Deploy on all chains.
# Example: ./shell/deploy-multi-chains.sh # Default deploys only to Sepolia
# Example: ./shell/deploy-multi-chains.sh --broadcast arbitrum_one mainnet
# Example: ./shell/deploy-multi-chains.sh --deterministic --broadcast mainnet

# Make sure you set-up your .env file first. See .env.example.

# Pre-requisites:
# - foundry (https://getfoundry.sh)

# Strict mode: https://gist.github.com/vncsna/64825d5609c146e80de8b1fd623011ca
set -euo pipefail

# color codes
EC='\033[0;31m' # Error Color
SC='\033[0;32m' # Success Color
WC='\033[0;33m' # Warn Color
IC='\033[0;36m' # Info Color
NC='\033[0m' # No Color

# Unicode characters for tick
TICK="\xE2\x9C\x94"

# Create deployments directory
deployments=./deployments
rm -rf $deployments
mkdir $deployments

# Declare chain IDs
ARBITRUM_CHAIN_ID="42161"
AVALANCHE_CHAIN_ID="43114"
BASE_CHAIN_ID="8453"
BSC_CHAIN_ID="56"
GNOSIS_CHAIN_ID="100"
MAINNET_CHAIN_ID="1"
OPTIMISM_CHAIN_ID="10"
POLYGON_CHAIN_ID="137"
SCROLL_CHAIN_ID="534352"
SEPOLIA_CHAIN_ID="11155111"

# from: https://docs.sablier.com/contracts/v2/deployments
ARBITRUM_COMPTROLLER="0x17Ec73692F0aDf7E7C554822FBEAACB4BE781762"
AVALANCHE_COMPTROLLER="0x66F5431B0765D984f82A4fc4551b2c9ccF7eAC9C"
BASE_COMPTROLLER="0x7Faaedd40B1385C118cA7432952D9DC6b5CbC49e"
BSC_COMPTROLLER="0x33511f69A784Fd958E6713aCaC7c9dCF1A5578E8"
GNOSIS_COMPTROLLER="0x73962c44c0fB4cC5e4545FB91732a5c5e87F55C2"
MAINNET_COMPTROLLER="0xC3Be6BffAeab7B297c03383B4254aa3Af2b9a5BA"
OPTIMISM_COMPTROLLER="0x1EECb6e6EaE6a1eD1CCB4323F3a146A7C5443A10"
POLYGON_COMPTROLLER="0x9761692EDf10F5F2A69f0150e2fd50dcecf05F2E"
SCROLL_COMPTROLLER="0x859708495E3B3c61Bbe19e6E3E1F41dE3A5C5C5b"
SEPOLIA_COMPTROLLER="0x2006d43E65e66C5FF20254836E63947FA8bAaD68"

# Source the .env file to load the variables
if [ -f .env ]; then
    source .env
else
    echo -e "${EC}Error: .env file not found${NC}"
    exit 1
fi

# Define chain configurations
declare -A chains
chains["arbitrum_one"]="$ARBITRUM_RPC_URL $ARBISCAN_API_KEY $ARBITRUM_CHAIN_ID $ARBITRUM_ADMIN $ARBITRUM_COMPTROLLER"
chains["avalanche"]="$AVALANCHE_RPC_URL $SNOWTRACE_API_KEY $AVALANCHE_CHAIN_ID $AVALANCHE_ADMIN $AVALANCHE_COMPTROLLER"
chains["base"]="$BASE_RPC_URL $BASESCAN_API_KEY $BASE_CHAIN_ID $BASE_ADMIN $BASE_COMPTROLLER"
chains["bnb_smart_chain"]="$BSC_RPC_URL $BSCSCAN_API_KEY $BSC_CHAIN_ID $BSC_ADMIN $BSC_COMPTROLLER"
chains["gnosis"]="$GNOSIS_RPC_URL $GNOSISSCAN_API_KEY $GNOSIS_CHAIN_ID $GNOSIS_ADMIN $GNOSIS_COMPTROLLER"
chains["mainnet"]="$MAINNET_RPC_URL $ETHERSCAN_API_KEY $MAINNET_CHAIN_ID $MAINNET_ADMIN $MAINNET_COMPTROLLER"
chains["optimism"]="$OPTIMISM_RPC_URL $OPTIMISTIC_API_KEY $OPTIMISM_CHAIN_ID $OPTIMISM_ADMIN $OPTIMISM_COMPTROLLER"
chains["polygon"]="$POLYGON_RPC_URL $POLYGONSCAN_API_KEY $POLYGON_CHAIN_ID $POLYGON_ADMIN $POLYGON_COMPTROLLER"
chains["scroll"]="$SCROLL_RPC_URL $SCROLL_API_KEY $SCROLL_CHAIN_ID $SCROLL_ADMIN $SCROLL_COMPTROLLER"
chains["sepolia"]="$SEPOLIA_RPC_URL $ETHERSCAN_API_KEY $SEPOLIA_CHAIN_ID $SEPOLIA_ADMIN $SEPOLIA_COMPTROLLER"

# Flag for broadcast deployment
BROADCAST_DEPLOYMENT=false

# Flag for deterministic deployment
DETERMINISTIC_DEPLOYMENT=false

# Flag for gas price
WITH_GAS_PRICE=false
GAS_PRICE=0

# Flag for all chains
ON_ALL_CHAINS=false

# Requested chains
requested_chains=()

# Check for arguments passed to the script
for ((i=1; i<=$#; i++)); do
    arg=${!i}

    # Check for '--broadcast' flag in the arguments
    if [[ $arg == "--broadcast" ]]; then
        BROADCAST_DEPLOYMENT=true
    fi

    # Check for '--broadcast' flag in the arguments
    if [[ $arg == "--deterministic" ]]; then
        DETERMINISTIC_DEPLOYMENT=true
    fi

    # Check for '--with-gas-price' flag in the arguments
    if [[ $arg == "--with-gas-price" ]]; then
        WITH_GAS_PRICE=true
        # Increment index to get the next argument, which should be the gas price
        ((i++))
        GAS_PRICE=${!i}
        if ! [[ $GAS_PRICE =~ ^[0-9]+$ ]]; then
            echo -e "${EC}Error: Invalid value for --with-gas-price, must be number${NC}"
            exit 1
        fi
    fi

    # Check for '--all' flag in the arguments
    if [[ $arg == "--all" ]]; then
        ON_ALL_CHAINS=true
        requested_chains=("${!chains[@]}")
    fi

    # Check for passed chains
    if [[ $arg != "--all" && $arg != "--deterministic" && $arg != "--broadcast"  && $arg != "--with-gas-price" && $ON_ALL_CHAINS == false ]]; then
        requested_chains+=("$arg")
    fi
done

# Set the default chain to Sepolia if no chains are requested
if [ ${#requested_chains[@]} -eq 0 ]; then
    requested_chains=("sepolia")
fi

# Compile the contracts
echo "Compiling the contracts..."
FOUNDRY_PROFILE=optimized forge build

# Deploy to requested chains
for chain in "${requested_chains[@]}"; do
    # Check if the requested chain is defined
    if [[ ! -v "chains[$chain]" ]]; then
        echo -e "\n${WC}Warning: Chain configuration for '$chain' not found.${NC}"
        continue
    fi

    # Split the configuration into RPC, API key and the Chain ID
    IFS=' ' read -r rpc_url api_key chain_id admin comptroller <<< "${chains[$chain]}"

    # Declare a deployment command
    deployment_command="";

    # Choose the script based on the flag
    if [[ $DETERMINISTIC_DEPLOYMENT == true ]]; then
        echo -e "\n${IC}Deploying deterministic contracts to $chain...${NC}"
        # Construct the command
        deployment_command="forge script script/DeployDeterministicProtocol2.s.sol \
        --rpc-url $rpc_url \
        --sig run(string,address,address) \
        \"ChainID_${chain_id}_Version_1.1.0\" \
        $admin \
        $comptroller \
        -vvv"
    else
        echo -e "\n${IC}Deploying contracts to $chain...${NC}"
        # Construct the command
        deployment_command="forge script script/DeployProtocol2.s.sol \
        --rpc-url $rpc_url \
        --sig run(address,address) \
        $admin \
        $comptroller \
        -vvv"
    fi

    # Append additional options if broadcast is enabled
    if [[ $BROADCAST_DEPLOYMENT == true ]]; then
        echo -e "${SC}+${NC} This deployment is broadcasted on $chain"
        deployment_command+=" --broadcast --verify --etherscan-api-key \"$api_key\""
    else
        echo -e "${SC}+${NC} Simulated on $chain"
    fi

    # Append additional options if gas price is enabled
    if [[ $WITH_GAS_PRICE == true ]]; then
        gas_price_in_gwei=$(echo "scale=2; $GAS_PRICE / 1000000000" | bc)
        echo -e "${SC}+${NC} Using gas price of $gas_price_in_gwei gwei"
        deployment_command+=" --with-gas-price $GAS_PRICE"
    fi

    # Run the deployment command
    output=$(FOUNDRY_PROFILE=optimized $deployment_command)

    # Create a file for the chain
    chain_file="$deployments/$chain.txt"
    touch "$chain_file"

    # Extract and save contract addresses
    nftDescriptor_address=$(echo "$output" | awk '/nftDescriptor: contract/{print $NF}')
    lockupLinear_address=$(echo "$output" | awk '/lockupLinear: contract/{print $NF}')
    lockupDynamic_address=$(echo "$output" | awk '/lockupDynamic: contract/{print $NF}')
    batch_address=$(echo "$output" | awk '/batch: contract/{print $NF}')
    merkleStreamerFactory_address=$(echo "$output" | awk '/merkleStreamerFactory: contract/{print $NF}')

    # Save to the chain file
    {
        echo "NFTDescriptor = $nftDescriptor_address"
        echo "LockupLinear = $lockupLinear_address"
        echo "LockupDynamic = $lockupDynamic_address"
        echo "SablierV2Batch = $batch_address"
        echo "SablierV2MerkleStreamerFactory = $merkleStreamerFactory_address"
    } >> "$chain_file"

    echo -e "${SC}$TICK Deployed on $chain. Addresses saved in $chain_file${NC}"
done

echo -e "\nAll deployments completed."
