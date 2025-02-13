#!/usr/bin/env bash

# Exit script as soon as a command fails.
set -o errexit

# Executes cleanup function at script exit.
trap cleanup EXIT

SOLIDITY_COVERAGE=$1

cleanup() {
  # Kill the ganache instance that we started (if we started one and if it's still running).
  if [ -n "$ganache_pid" ] && ps -p $ganache_pid > /dev/null; then
    kill -9 $ganache_pid
  fi
}

if [ "$SOLIDITY_COVERAGE" = true ]; then
  ganache_port=8555
else
  ganache_port=8545
fi

ganache_running() {
  nc -z localhost "$ganache_port"
}

start_ganache() {
  local mnemonic="sport pattern badge pretty abandon venture stone cupboard plunge firm bulk essence"
  local balance=10000
  local gasPrice=1000000000
  local gasLimit=0xfffffffffff

  if [ "$SOLIDITY_COVERAGE" = true ]; then
    npx testrpc-sc --port "$ganache_port" -m "$mnemonic" -e "$balance" -g "$gasPrice" -l "$gasLimit" -a 20 > /dev/null &
  else
    npx ganache-cli --port "$ganache_port" -m "$mnemonic" -e "$balance" -g "$gasPrice" -l "$gasLimit" -a 20 > /dev/null &
  fi

  ganache_pid=$!

  echo "Waiting for ganache to launch on port "$ganache_port"..."

  while ! ganache_running; do
    sleep 0.1 # wait for 1/10 of the second before check again
  done

  echo "Ganache launched!"
}

if ganache_running; then
  echo "Using existing ganache instance"
else
  echo "Starting our own ganache instance"
  start_ganache
fi

if [ "$SOLIDITY_COVERAGE" = true ]; then
  npx solidity-coverage

  if [ "$CONTINUOUS_INTEGRATION" = true ]; then
    cat coverage/lcov.info | npx coveralls
  fi
else
  node $NODE_DEBUG_OPTION node_modules/.bin/truffle test --network ganache
fi
