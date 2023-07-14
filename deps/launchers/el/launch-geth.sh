#!/bin/bash

env_vars=(
  "EXECUTION_CHECKPOINT_FILE"
  "EXECUTION_CLIENT"
  "EXECUTION_ENGINE_HTTP_PORT"
  "EXECUTION_ENGINE_WS_PORT"
  "EXECUTION_GENESIS_FILE"
  "EXECUTION_HTTP_APIS"
  "EXECUTION_HTTP_PORT"
  "EXECUTION_LAUNCHER"
  "EXECUTION_LOG_LEVEL"
  "EXECUTION_METRIC_PORT"
  "EXECUTION_NODE_DIR"
  "EXECUTION_P2P_PORT"
  "EXECUTION_WS_APIS"
  "EXECUTION_WS_PORT"
  "IP_ADDRESS"
  "IP_SUBNET"
  "JWT_SECRET_FILE"
  "CHAIN_ID"
)

# verify vars we need are set and available.
for var in "${env_vars[@]}" ; do
    if [[ -z "${!var}" ]]; then
        echo "GETH error in geth var check."
        echo "$var not set"
        exit 1
    fi
done


while [ ! -f "$EXECUTION_CHECKPOINT_FILE" ]; do
  echo "Waiting for execution checkpoint file: $EXECUTION_CHECKPOINT_FILE"
    sleep 1
done

# Time for execution clients to start up.
# go geth init
echo "GETH: Init the genesis"
geth init \
    --datadir "$EXECUTION_NODE_DIR" \
    "$EXECUTION_GENESIS_FILE"

# Now start geth.
echo "Starting geth"

log_file="/logs/service_$CONTAINER_NAME--geth"

if [ -f "$log_file" ]; then
  echo "Log file $log_file exists"
else
  mkdir /logs
  touch $log_file
fi

geth \
  --datadir="$EXECUTION_NODE_DIR" \
  --networkid="$CHAIN_ID" \
  --port "$EXECUTION_P2P_PORT" \
  --http --http.api "$EXECUTION_HTTP_APIS" \
  --http.port "$EXECUTION_HTTP_PORT" \
  --http.addr 0.0.0.0 \
  --http.corsdomain "*" \
  --http.vhosts="*" \
  --ws --ws.api "$EXECUTION_WS_APIS" \
  --ws.port="$EXECUTION_WS_PORT" \
  --ws.addr 0.0.0.0 \
  --gcmode=archive \
  --authrpc.port="$EXECUTION_ENGINE_HTTP_PORT" \
  --authrpc.addr=0.0.0.0 \
  --authrpc.vhosts="*" \
  --authrpc.jwtsecret="$JWT_SECRET_FILE" \
  --nat "extip:$IP_ADDRESS" \
  --rpc.allow-unprotected-txs \
  --allow-insecure-unlock \
  --netrestrict="$IP_SUBNET" \
  --syncmode=full \
  --vmodule=rpc=5 \
  --discovery.dns="" \
  > $log_file 2>&1
