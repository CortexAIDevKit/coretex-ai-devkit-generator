#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <owner/repo> <ruleset-json>" >&2
  exit 2
fi

REPO_FULL="$1"
RULESET_JSON="$2"

gh api -X POST "repos/${REPO_FULL}/rulesets" \
  --input "$RULESET_JSON" \
  >/dev/null

echo "✅ Applied ruleset from ${RULESET_JSON} to ${REPO_FULL}"
