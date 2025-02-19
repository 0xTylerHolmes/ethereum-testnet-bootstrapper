#!/bin/bash

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

if [ "$RUN_JSON_RPC_SNOOPER" == "true" ]; then
  echo "Launching json_rpc_snoop."
  json_rpc_snoop -p "$CL_EXECUTION_ENGINE_HTTP_PORT" http://localhost:"$EXECUTION_ENGINE_HTTP_PORT" 2>&1 | tee "$EXECUTION_NODE_DIR/json_rpc_snoop.log" &
fi

EXECUTION_CMD="geth"
EXECUTION_CMD+=" --verbosity=$EXECUTION_LOG_LEVEL"
EXECUTION_CMD+=" --datadir=$EXECUTION_NODE_DIR"
EXECUTION_CMD+=" --networkid=$CHAIN_ID"
EXECUTION_CMD+=" --port=$EXECUTION_P2P_PORT"
EXECUTION_CMD+=" --http"
EXECUTION_CMD+=" --http.addr=0.0.0.0"
EXECUTION_CMD+=" --http.port=$EXECUTION_HTTP_PORT"
EXECUTION_CMD+=" --http.vhosts=*"
EXECUTION_CMD+=" --http.corsdomain=*"
EXECUTION_CMD+=" --http.api=$EXECUTION_HTTP_APIS"
EXECUTION_CMD+=" --ws"
EXECUTION_CMD+=" --ws.addr=0.0.0.0"
EXECUTION_CMD+=" --ws.port=$EXECUTION_WS_PORT"
EXECUTION_CMD+=" --ws.api=$EXECUTION_WS_APIS"
EXECUTION_CMD+=" --ws.origins=*"
EXECUTION_CMD+=" --allow-insecure-unlock"
EXECUTION_CMD+=" --nat=extip:$IP_ADDRESS"
EXECUTION_CMD+=" --authrpc.port=$EXECUTION_ENGINE_HTTP_PORT"
EXECUTION_CMD+=" --authrpc.addr=0.0.0.0"
EXECUTION_CMD+=" --authrpc.vhosts=*"
EXECUTION_CMD+=" --authrpc.jwtsecret=$JWT_SECRET_FILE"
EXECUTION_CMD+=" --syncmode=full"
EXECUTION_CMD+=" --rpc.allow-unprotected-txs"
EXECUTION_CMD+=" --metrics"
EXECUTION_CMD+=" --metrics.addr=0.0.0.0"
EXECUTION_CMD+=" --metrics.port=$EXECUTION_METRIC_PORT"
EXECUTION_CMD+=" --ipcdisable=true"
EXECUTION_CMD+=" --netrestrict=$IP_SUBNET"
#--vmodule=rpc=5 \
#--discovery.dns=""
#--gcmode=archive \
#--syncmode=full \
#--password
#--unlock

echo "Launching geth execution client."
eval "$EXECUTION_CMD"