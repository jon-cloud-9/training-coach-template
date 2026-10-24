#!/usr/bin/env bash
# Tests for scripts/setup-state.sh. Uses a temp dir copy so the real config/ is untouched.
HERE="$(cd "$(dirname "$0")" && pwd)"
SCRIPT="$HERE/../setup-state.sh"
pass=0; fail=0
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
mkdir -p "$T/scripts"; cp "$SCRIPT" "$T/scripts/setup-state.sh" 2>/dev/null
S="$T/scripts/setup-state.sh"

check() { # name expected actual
  if [ "$2" = "$3" ]; then pass=$((pass+1)); echo "PASS: $1"
  else fail=$((fail+1)); echo "FAIL: $1 (expected '$2', got '$3')"; fi
}
fresh() { rm -rf "$T/config"; }
all_ids="s04 s05 s06 s07 s08 s09 s10 s11 s12 s13 s14 s15 s16 s17"

fresh
check "next on fresh state is s04" "s04" "$(bash "$S" next 2>/dev/null)"

fresh; bash "$S" mark s04 >/dev/null 2>&1
check "mark then next advances" "s05" "$(bash "$S" next 2>/dev/null)"

fresh; bash "$S" mark s04 >/dev/null 2>&1; bash "$S" mark s06 >/dev/null 2>&1
check "next returns first incomplete step after interruption" "s05" "$(bash "$S" next 2>/dev/null)"

fresh; for i in $all_ids; do bash "$S" mark "$i" >/dev/null 2>&1; done
check "done after all marked" "done" "$(bash "$S" next 2>/dev/null)"

fresh; bash "$S" mark s99 >/dev/null 2>&1; rc=$?
check "unknown id is rejected with exit 2" "2" "$rc"

echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
