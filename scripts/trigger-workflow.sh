#!/bin/bash
set -e

TOKEN=$1
REPO=$2
EVENT_TYPE=$3

response=$(curl -s -w "%{http_code}" -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -d "{
        \"event_type\": \"$EVENT_TYPE\",
        \"client_payload\": {
          \"skip_slack\": \"false\"
        }
      }" \
  "https://api.github.com/repos/$REPO/dispatches" -o response_body.txt)

if [ "$response" -ne 200 ] && [ "$response" -ne 204 ]; then
  echo "Error: Failed to trigger repository dispatch. HTTP status code: $response"
  cat response_body.txt
  exit 1
else
  echo "Successfully triggered repository dispatch."
fi
