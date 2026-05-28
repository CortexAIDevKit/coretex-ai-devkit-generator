# cortex-ai-devkit-generator

This repository automates the creation of new Cortex AI DevKit skills and prompts repositories with the help of [copier](https://copier.readthedocs.io/en/stable/).

## Prerequisites

- A target GitHub organization where new repositories will be created.
- The GitHub App [`cortex-ai-devkit-bot`](https://github.com/apps/cortex-ai-devkit-bot/installations/new) installed on the target GitHub organization, with `Members: Read` permission so the approval workflow can verify team membership.
- A GitHub team named `cortex-core` in the target organization. Only members of this team are allowed to approve requests.

> [!WARNING]
> If the GitHub App [`cortex-ai-devkit-bot`](https://github.com/apps/cortex-ai-devkit-bot/installations/new) is not installed, or the target organization already has a repository with the same name, the workflow will fail. A comment will be added on the issue explaining why.

## How to Use ?

1. Open a [new issue](https://github.com/CortexAIDevKit/cortex-ai-devkit-generator/issues/new/choose) using either the **Skill request** or **Prompt request** template.
2. Fill in the fields and submit the issue.
3. A member of the [`@CortexAIDevKit/cortex-core`](https://github.com/orgs/CortexAIDevKit/teams/cortex-core) team reviews the request and comments `/approve` on the issue to trigger scaffolding.

## Workflows

```mermaid
flowchart TD
    A[User opens issue with<br/>skill-request or prompt-request label] --> B[Awaits approval]
    B --> C{Comment starts with<br/>/approve and issue open?}
    C -- No --> Z[Workflow skipped]
    C -- Yes --> D[approve.yml: gate job]
    D --> E{GitHub App installed<br/>on org?}
    E -- No --> F[Comment: install app<br/>and fail]
    E -- Yes --> G{Commenter in<br/>@CortexAIDevKit/cortex-core?}
    G -- No --> H[Comment: not allowed<br/>to approve and fail]
    G -- Yes --> I{Issue label}
    I -- skill-request --> J[skill-request.yml<br/>workflow_call]
    I -- prompt-request --> K[prompt-request.yml<br/>workflow_call]
    J --> L[copier scaffold<br/>+ create repo + push]
    K --> L
    L --> M[Comment success link<br/>on issue]
```

## Contact

If you have any enhancement suggests or issues, feel free to open a thread in the [discussions](https://github.com/CortexAIDevKit/cortex-ai-devkit-lab/discussions)