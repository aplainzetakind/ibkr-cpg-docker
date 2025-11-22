#!/usr/bin/env bash
set -euo pipefail

# Start Client Portal Gateway
CPG_DIR="/clientportal"
CPG_PID_FILE="/tmp/cpg.pid"

echo "Starting IB Client Portal Gateway..."

pushd "$CPG_DIR" > /dev/null
./bin/run.sh root/conf.yaml &
echo $! > "$CPG_PID_FILE"
popd > /dev/null

echo "Waiting for CPG to initialize..."
sleep 10

if ! kill -0 "$(cat "$CPG_PID_FILE")" 2>/dev/null; then
    echo "Error: CPG failed to start."
    exit 1
fi

echo "CPG started successfully with PID $(cat "$CPG_PID_FILE")."


echo "Authenticating to CPG..."
/root/login.sh

printenv >> /etc/environment

echo "Starting cron..."
exec cron -f
