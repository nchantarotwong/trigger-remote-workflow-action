#!/bin/bash
set -e

TOKEN=$1
REPO=$2
REF=$3
EVENT_TYPE=$4
TRIGGER_TIMESTAMP=$5

max_retries=30
attempt=0
workflow_run_url=""
workflow_run_id=""

while [ -z "$workflow_run_url" ] && [ $attempt -lt $max_retries ]; do
  response=$(curl -s -H "Authorization: token $TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/$REPO/actions/runs?branch=$REF")

  workflow_data=$(echo "$response" | jq -c \
    --arg ref "$REF" \
    --arg event_type "$EVENT_TYPE" \
    --arg trigger_time "$TRIGGER_TIMESTAMP" \
    '[.workflow_runs[]
      | select(.head_branch == $ref
               and .event == "repository_dispatch"
               and .display_title == $event_type
               and .created_at > $trigger_time)]
      | first')

  if [ "$workflow_data" != "null" ]; then
    workflow_run_url=$(echo "$workflow_data" | jq -r '.url')
    workflow_run_id=$(echo "$workflow_data" | jq -r '.id')
    echo "Found matching workflow run: $workflow_run_url (ID: $workflow_run_id)"
    break
  fi

  echo "No matching workflow run found, retrying in 10 seconds..."
  sleep 10
  attempt=$((attempt + 1))
done

if [ -z "$workflow_run_url" ]; then
  echo "Error: Timed out waiting for workflow run."
  exit 1
fi

echo "workflow_url=$workflow_run_url"
echo "workflow_run_id=$workflow_run_id"
