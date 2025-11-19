#!/bin/bash

export GOPATH=~/go
export PATH=$PATH:$GOPATH/bin
go build -o ./build/impactchaind ./cmd/impactchaind
go build -o ./build/impactchaincli ./cmd/impactchaincli
mkdir $GOPATH/bin
cp ./build/impactchaind $GOPATH/bin
cp ./build/impactchaincli $GOPATH/bin

CHAINID="impactchain-1337"

cd tests-solidity

if command -v yarn &> /dev/null; then
    yarn install
else
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt update && sudo apt install yarn
    yarn install
fi

chmod +x ./init-test-node.sh
./init-test-node.sh > impactchaind.log &
sleep 5
impactchaincli rest-server --laddr "tcp://localhost:8545" --unlock-key localkey,user1,user2 --chain-id $CHAINID --trace --wsport 8546 --rpc-api="web3,eth,net,personal" > impactchaincli.log &

cd suites/initializable
yarn test-impactchain

ok=$?

if (( $? != 0 )); then
    echo "initializable test failed: exit code $?"
fi

killall impactchaincli
killall impactchaind

echo "Script exited with code $ok"
exit $ok

# initializable-buidler fails on CI, re-add later

./../../init-test-node.sh > impactchaind.log &
sleep 5
impactchaincli rest-server --laddr "tcp://localhost:8545" --unlock-key localkey,user1,user2 --chain-id $CHAINID --trace --wsport 8546 --rpc-api="web3,eth,net,personal" > impactchaincli.log &

cd ../initializable-buidler
yarn test-impactchain

ok=$(($? + $ok))

if (( $? != 0 )); then
    echo "initializable-buidler test failed: exit code $?"
fi

killall impactchaincli
killall impactchaind

echo "Script exited with code $ok"
exit $ok