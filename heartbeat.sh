#!/usr/bin/env bash

exec 2>/dev/null

RESPONSE=$(curl \
    --url http://localhost:5000/v1/api/iserver/auth/status \
    --request POST \
    --header 'Content-Type:application/json' \
    --data '{}'
)

AUTHENTICATED=$(echo "$RESPONSE" | sed -n 's/.*"authenticated":\s*\(true\|false\).*/\1/p')
CONNECTED=$(echo "$RESPONSE" | sed -n 's/.*"connected":\s*\(true\|false\).*/\1/p')

MESSAGE=$( [[ $AUTHENTICATED == "true" ]] && [[ $CONNECTED == "true" ]] && echo "HEARTBEAT OK | " || echo "HEARTBEAT ERROR | ")

if [[ $AUTHENTICATED == "true" ]]; then
    MESSAGE+="AUTHENTICATED, "
else
    MESSAGE+="NOT AUTHENTICATED, "
fi

if [[ $CONNECTED == "true" ]]; then
    MESSAGE+="CONNECTED."
else
    MESSAGE+="NOT CONNECTED."
fi

echo ["$(date -Iseconds)"] "$MESSAGE"
