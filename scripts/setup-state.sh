#!/usr/bin/env bash
# Tracks which /setup steps are complete, so setup can resume after an interruption.
# State lives in config/setup-state.json: {"version":1,"completed":["s04",...],"updated":"<ISO>"}
#
# Usage:
#   setup-state.sh next        print the first step (s04..s17) not yet complete, or "done"
#   setup-state.sh mark <id>   record a step as complete
#   setup-state.sh reset       clear all progress
#
# Plain bash only (no jq: it is not on a fresh Mac). Works on macOS bash 3.2.
set -euo pipefail

STEPS="s04 s05 s06 s07 s08 s09 s10 s11 s12 s13 s14 s15 s16 s17"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
STATE="$ROOT/config/setup-state.json"

completed() { # print completed ids, one per line
  [ -f "$STATE" ] || return 0
  grep -o '"s[0-9][0-9]"' "$STATE" | tr -d '"' || true
}

write_state() { # ids as args
  local list="" id
  for id in "$@"; do
    [ -n "$id" ] || continue
    list="${list:+$list,}\"$id\""
  done
  mkdir -p "$ROOT/config"
  printf '{"version":1,"completed":[%s],"updated":"%s"}\n' \
    "$list" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$STATE"
}

is_valid() { case " $STEPS " in *" $1 "*) return 0 ;; *) return 1 ;; esac; }

case "${1:-}" in
  next)
    done_list=" $(completed | tr '\n' ' ') "
    for id in $STEPS; do
      case "$done_list" in *" $id "*) ;; *) echo "$id"; exit 0 ;; esac
    done
    echo "done"
    ;;
  mark)
    id="${2:-}"
    if ! is_valid "$id"; then
      echo "setup-state: unknown step id '$id' (expected s04..s17)" >&2
      exit 2
    fi
    # keep canonical order, de-duplicated
    have=" $(completed | tr '\n' ' ') $id "
    out=()
    for s in $STEPS; do
      case "$have" in *" $s "*) out+=("$s") ;; esac
    done
    write_state "${out[@]}"
    ;;
  reset)
    write_state
    ;;
  *)
    echo "usage: $0 next | mark <id> | reset" >&2
    exit 2
    ;;
esac
