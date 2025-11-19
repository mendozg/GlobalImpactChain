#!/bin/bash

KEY="mykey"
CHAINID="impactchain-1"
MONIKER="localtestnet"

# remove existing daemon and client
rm -rf ~/.impactchain*

make install

impactchaincli config keyring-backend test

# Set up config for CLI
impactchaincli config chain-id $CHAINID
impactchaincli config output json
impactchaincli config indent true
impactchaincli config trust-node true

# if $KEY exists it should be deleted
impactchaincli keys add $KEY

# Set moniker and chain-id for Impactchain (Moniker can be anything, chain-id must be an integer)
impactchaind init $MONIKER --chain-id $CHAINID

# Change parameter token denominations to aphoton
cat $HOME/.impactchaind/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="aphoton"' > $HOME/.impactchaind/config/tmp_genesis.json && mv $HOME/.impactchaind/config/tmp_genesis.json $HOME/.impactchaind/config/genesis.json
cat $HOME/.impactchaind/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="aphoton"' > $HOME/.impactchaind/config/tmp_genesis.json && mv $HOME/.impactchaind/config/tmp_genesis.json $HOME/.impactchaind/config/genesis.json
cat $HOME/.impactchaind/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="aphoton"' > $HOME/.impactchaind/config/tmp_genesis.json && mv $HOME/.impactchaind/config/tmp_genesis.json $HOME/.impactchaind/config/genesis.json
cat $HOME/.impactchaind/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="aphoton"' > $HOME/.impactchaind/config/tmp_genesis.json && mv $HOME/.impactchaind/config/tmp_genesis.json $HOME/.impactchaind/config/genesis.json

# increase block time (?)
cat $HOME/.impactchaind/config/genesis.json | jq '.consensus_params["block"]["time_iota_ms"]="30000"' > $HOME/.impactchaind/config/tmp_genesis.json && mv $HOME/.impactchaind/config/tmp_genesis.json $HOME/.impactchaind/config/genesis.json

if [[ $1 == "pending" ]]; then
    echo "pending mode on; block times will be set to 30s."
    # sed -i 's/create_empty_blocks_interval = "0s"/create_empty_blocks_interval = "30s"/g' $HOME/.impactchaind/config/config.toml
    sed -i 's/timeout_propose = "3s"/timeout_propose = "30s"/g' $HOME/.impactchaind/config/config.toml
    sed -i 's/timeout_propose_delta = "500ms"/timeout_propose_delta = "5s"/g' $HOME/.impactchaind/config/config.toml
    sed -i 's/timeout_prevote = "1s"/timeout_prevote = "10s"/g' $HOME/.impactchaind/config/config.toml
    sed -i 's/timeout_prevote_delta = "500ms"/timeout_prevote_delta = "5s"/g' $HOME/.impactchaind/config/config.toml
    sed -i 's/timeout_precommit = "1s"/timeout_precommit = "10s"/g' $HOME/.impactchaind/config/config.toml
    sed -i 's/timeout_precommit_delta = "500ms"/timeout_precommit_delta = "5s"/g' $HOME/.impactchaind/config/config.toml
    sed -i 's/timeout_commit = "5s"/timeout_commit = "150s"/g' $HOME/.impactchaind/config/config.toml
fi

# Allocate genesis accounts (cosmos formatted addresses)
impactchaind add-genesis-account $(impactchaincli keys show $KEY -a) 100000000000000000000aphoton

# Sign genesis transaction
impactchaind gentx --name $KEY --amount=1000000000000000000aphoton --keyring-backend test

# Collect genesis tx
impactchaind collect-gentxs

# Run this to ensure everything worked and that the genesis file is setup correctly
impactchaind validate-genesis

# Command to run the rest server in a different terminal/window
echo -e '\nrun the following command in a different terminal/window to run the REST server and JSON-RPC:'
echo -e "impactchaincli rest-server --laddr \"tcp://localhost:8545\" --unlock-key $KEY --chain-id $CHAINID --trace\n"

# Start the node (remove the --pruning=nothing flag if historical queries are not needed)
impactchaind start --pruning=nothing --rpc.unsafe --log_level "main:info,state:info,mempool:info" --trace
