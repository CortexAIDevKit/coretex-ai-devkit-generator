#!/usr/bin/env bash

set -euo pipefail

if [[ "$#" -ne 2 ]]; then
  echo "Usage: $0 <owner/repo> <labels-json-file>" >&2
  exit 1
fi

REPO_FULL="$1"
LABELS_FILE="$2"

if [[ ! -f "$LABELS_FILE" ]]; then
  echo "Labels file not found: $LABELS_FILE" >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI is required but not installed." >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required but not installed." >&2
  exit 1
fi

if [[ -z "${GH_TOKEN:-}" && -z "${GITHUB_TOKEN:-}" ]]; then
  echo "Set GH_TOKEN or GITHUB_TOKEN before running this script." >&2
  exit 1
fi

jq -e 'type == "array" and all(.[]; has("name") and has("description") and has("color"))' "$LABELS_FILE" >/dev/null

echo "Rewriting labels for $REPO_FULL from $LABELS_FILE"

# Delete all existing labels first so the label set fully matches the JSON source.
gh label list \
  --repo "$REPO_FULL" \
  --limit 1000 \
  --json name \
| jq -r '.[].name' \
| while IFS= read -r existing_label; do
  [[ -z "$existing_label" ]] && continue
  gh label delete "$existing_label" --repo "$REPO_FULL" --yes
done

jq -c '.[]' "$LABELS_FILE" | while IFS= read -r label; do
  name="$(jq -r '.name' <<<"$label")"
  description="$(jq -r '.description // ""' <<<"$label")"
  color="$(jq -r '.color' <<<"$label")"

  gh label create "$name" \
    --repo "$REPO_FULL" \
    --description "$description" \
    --color "$color"
done

echo "Labels rewritten successfully for $REPO_FULL"