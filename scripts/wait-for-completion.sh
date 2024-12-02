#!/bin/bash
set -e

TOKEN=$1
WORKFLOW_URL=$2

max_retries=60
attempt=0

while [ $attempt -lt $max_retries ]; do
  response=$(curl -s -H "Authorization: token $TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "$WORKFLOW_URL")

  status=$(echo "$response" | jq -r '.status')
  conclusion=$(echo "$response" | jq -r '.conclusion')

  if [ "$status" == "completed" ]; then
    echo "Workflow completed with conclusion: $conclusion"
    if [ "$conclusion" != "success" ]; then
      exit 1
    fi
    exit 0
  fi

  echo "Workflow still in progress, retrying in 30 seconds..."
  sleep 30
  attempt=$((attempt + 1))
done

echo "Error: Timed out waiting for workflow completion."
exit 1
