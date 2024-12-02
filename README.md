# trigger-remote-workflow-action

[![GitHub Release](https://img.shields.io/github/v/release/your-username/trigger-remote-workflow-action)](https://github.com/your-username/trigger-remote-workflow-action/releases)
[![License](https://img.shields.io/github/license/your-username/trigger-remote-workflow-action)](./LICENSE)

This GitHub Action triggers a repository dispatch event in a remote repository, polls for the corresponding workflow run, and waits for its completion. It's designed for workflows where you need to remotely trigger and monitor a dependent workflow.

---

## Features

- **Trigger workflows remotely** using a `repository_dispatch` event.
- **Poll for workflow status** in the target repository.
- **Wait for workflow completion** and handle success or failure.
- **Customizable inputs** for repository, branch, and event type.

---

## Inputs

| Name              | Description                                                                 | Required | Default |
|-------------------|-----------------------------------------------------------------------------|----------|---------|
| `github_token`    | A GitHub token with repository permissions to trigger and monitor workflows. | Yes      | N/A     |
| `repository`      | The target repository in the format `owner/repo`.                          | Yes      | N/A     |
| `event_type`      | The custom event type for the `repository_dispatch` payload.               | Yes      | N/A     |
| `ref`             | The branch or ref for the workflow run.                                    | Yes      | N/A     |
| `trigger_timestamp` | A UTC timestamp to start polling for workflows created after this time.    | Yes      | N/A     |

---

## Outputs

| Name              | Description                          |
|-------------------|--------------------------------------|
| `workflow_url`    | The URL of the triggered workflow.  |
| `workflow_run_id` | The ID of the triggered workflow.   |

---

## Example Usage

### Trigger and Monitor a Workflow

```yaml
name: Trigger and Poll Remote Workflow

on:
  workflow_dispatch: # Manual trigger for this workflow

jobs:
  trigger-workflow:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout
      uses: actions/checkout@v3

    - name: Trigger and Poll Workflow
      uses: your-username/trigger-remote-workflow-action@v1.0.0
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        repository: "owner/repo"
        event_type: "trigger-dev-smoke-tests"
        ref: "main"
        trigger_timestamp: ${{ github.event.created_at }}
