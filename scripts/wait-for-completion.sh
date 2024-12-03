#!/bin/bash
set -e

TOKEN=$1
WORKFLOW_URL=$2

max_retries=${MAX_RETRIES:-60}
sleep_duration=${SLEEP_DURATION:-30}
attempt=0

# Debug logging
echo "Debug: Workflow URL: $WORKFLOW_URL"

while [ $attempt -lt "$max_retries" ]; do
  response=$(curl -s -H "Authorization: token $TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "$WORKFLOW_URL")

  echo "Debug: API Response: $response"

  status=$(echo "$response" | jq -r '.status')
  conclusion=$(echo "$response" | jq -r '.conclusion')

  if [ -z "$status" ] || [ "$status" == "null" ]; then
    echo "Error: Failed to retrieve workflow status from API response."
    echo "Response: $response"
    exit 1
  fi

  echo "Debug: Status: $status, Conclusion: $conclusion"

  if [ "$status" == "completed" ]; then
    if [ -z "$conclusion" ] || [ "$conclusion" == "null" ]; then
      echo "Error: Failed to retrieve workflow conclusion from API response."
      echo "Response: $response"
      exit 1
    fi

    echo "Workflow completed with conclusion: $conclusion"
    if [ "$conclusion" != "success" ]; then
      exit 1
    fi
    exit 0
  fi

  echo "Workflow still in progress, retrying in $sleep_duration seconds..."
  sleep "$sleep_duration"
  attempt=$((attempt + 1))
done

echo "Error: Timed out waiting for workflow completion."
exit 1
