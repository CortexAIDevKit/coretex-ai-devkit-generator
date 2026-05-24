#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <owner/repo>" >&2
  exit 2
fi

REPO_FULL="$1"

gh api -X PATCH "repos/${REPO_FULL}" \
  -F has_wiki=false \
  -F has_projects=false \
  -F allow_merge_commit=false \
  -F allow_squash_merge=true \
  -f squash_merge_commit_title=PR_TITLE \
  -f squash_merge_commit_message=COMMIT_MESSAGES \
  -F allow_update_branch=true \
  -F delete_branch_on_merge=true \
  >/dev/null

echo "✅ Applied repo settings to ${REPO_FULL}"
