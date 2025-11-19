#!/bin/sh
impactchaind --home /impactchain/node$ID/impactchaind/ start > impactchaind.log &
sleep 5
impactchaincli rest-server --laddr "tcp://localhost:8545" --chain-id "impactchain-7305661614933169792" --trace --rpc-api="web3,eth,net,personal" > impactchaincli.log &
tail -f /dev/null