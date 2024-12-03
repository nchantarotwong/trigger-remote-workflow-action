#!/bin/bash
set -e

TOKEN=$1
REPO=$2
EVENT_TYPE=$3
SKIP_SLACK=$4

echo "Debug: skip_slack=$SKIP_SLACK"

response=$(curl -s -w "%{http_code}" -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -d '{
        "event_type": "'"$EVENT_TYPE"'",
        "client_payload": {
          "skip_slack": "'"$SKIP_SLACK"'"
        }
      }' \
  "https://api.github.com/repos/$REPO/dispatches" -o response_body.txt)

http_code=$(tail -n1 <<< "$response")
if [[ "$http_code" -ne 200 ]] && [[ "$http_code" -ne 204 ]]; then
  echo "Error: Failed to trigger repository dispatch. HTTP status code: $http_code"
  echo "Response body:"
  cat response_body.txt
  exit 1
else
  echo "Successfully triggered repository dispatch."
fi
