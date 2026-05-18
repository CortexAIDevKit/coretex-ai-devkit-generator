#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <target_org> <project_dir>" >&2
  exit 2
fi

TARGET_ORG="$1"
PROJECT_DIR="$2"

STATUS=$(curl -s \
  -o /dev/null \
  -w "%{http_code}" \
  -H "Authorization: Bearer $GH_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/${TARGET_ORG}/${PROJECT_DIR}")

if [ "$STATUS" = "200" ]; then
  gh issue comment "$ISSUE_NUMBER" \
    --repo "$GH_REPO" \
    --body \
    "❌ Preflight failed.

    Repository \`${TARGET_ORG}/${PROJECT_DIR}\` already exists.

    Choose a different domain/action/skill_name and retry."

  exit 1
fi

if [ "$STATUS" != "404" ]; then
  echo "Unexpected HTTP ${STATUS}"
  exit 1
fi

echo "✅ Repository available"
