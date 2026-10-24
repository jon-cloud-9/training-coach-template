#!/usr/bin/env bash
# PostToolUse hook: when a week's plan.md is edited, remind Claude to sync that
# week to the Notion "Training Sessions" database before finishing the turn.
# Reads the hook payload on stdin; prints nothing for any other file.
# Plain bash, grep and sed only (no jq: it is not on a fresh Mac).

payload="$(cat)"

# Pull a JSON string value by key, undoing the common escapes (\/ \" \\).
json_str() {
  printf '%s' "$payload" | tr '\n' ' ' \
    | grep -oE '"'"$1"'"[[:space:]]*:[[:space:]]*"([^"\\]|\\.)*"' | head -1 \
    | sed -E 's/^"[^"]*"[[:space:]]*:[[:space:]]*"//; s/"$//' \
    | sed -e 's#\\/#/#g' -e 's/\\"/"/g' -e 's/\\\\/\\/g'
}

f="$(json_str filePath)"
[ -n "$f" ] || f="$(json_str file_path)"

case "$f" in
  */campaigns/*/weeks/week-*/plan.md|campaigns/*/weeks/week-*/plan.md)
    esc="$(printf '%s' "$f" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')"
    printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"Week plan edited: %s. Before ending this turn, sync this week to the Notion Training Sessions database (CLAUDE.md, \\"Writing to Notion\\"): update moved/changed rows by Session ID, add new ones, mark removed ones Dropped, copy the changelog line into Last change. Garmin calendar changes still need explicit approval."}}\n' "$esc"
    ;;
esac
