#!/usr/bin/env bash
# PostToolUse hook: when a week's plan.md is edited, remind Claude to sync that
# week to the Notion "Training Sessions" database before finishing the turn.
# Reads the hook payload on stdin; prints nothing for any other file.
f="$(jq -r '.tool_response.filePath // .tool_input.file_path // empty')"
case "$f" in
  */campaigns/*/weeks/week-*/plan.md|campaigns/*/weeks/week-*/plan.md)
    jq -n --arg f "$f" '{hookSpecificOutput: {hookEventName: "PostToolUse",
      additionalContext: ("Week plan edited: " + $f + ". Before ending this turn, sync this week to the Notion Training Sessions database (CLAUDE.md, \"Writing to Notion\"): update moved/changed rows by Session ID, add new ones, mark removed ones Dropped, copy the changelog line into Last change. Garmin calendar changes still need explicit approval.")}}'
    ;;
esac
