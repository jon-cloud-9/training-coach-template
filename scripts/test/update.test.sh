#!/usr/bin/env bash
# Tests for scripts/update-shared.sh, using fake upstream and user folders.
HERE="$(cd "$(dirname "$0")" && pwd)"
SCRIPT="$HERE/../update-shared.sh"
pass=0; fail=0
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT

check() { # name expected actual
  if [ "$2" = "$3" ]; then pass=$((pass+1)); echo "PASS: $1"
  else fail=$((fail+1)); echo "FAIL: $1 (expected '$2', got '$3')"; fi
}

# make_upstream <dir> <version> [extra TEMPLATE_FILES line]
make_upstream() {
  local d="$1" v="$2" extra="${3:-}"
  rm -rf "$d"; mkdir -p "$d/.claude/skills/x" "$d/scripts"
  echo "$v" > "$d/VERSION"
  echo "claude-$v" > "$d/CLAUDE.md"
  echo "skill-$v" > "$d/.claude/skills/x/SKILL.md"
  printf '#!/usr/bin/env bash\necho %s\n' "$v" > "$d/scripts/tool.sh"
  { printf 'CLAUDE.md\n.claude/skills/x/SKILL.md\nscripts/tool.sh\nscripts/update-shared.sh\nVERSION\nTEMPLATE_FILES\n'
    [ -n "$extra" ] && echo "$extra"; } > "$d/TEMPLATE_FILES"
  cp "$SCRIPT" "$d/scripts/update-shared.sh"
}
# make_user <dir>: a user folder at 0.1.0 with personal data, checksums recorded
make_user() {
  local d="$1"
  make_upstream "$d" 0.1.0
  mkdir -p "$d/athlete" "$d/campaigns/c" "$d/config"
  echo "my profile" > "$d/athlete/profile.md"
  echo "my plan" > "$d/campaigns/c/plan.md"
  echo "my private settings" > "$d/config/intervals.env"
  bash "$d/scripts/update-shared.sh" --record-checksums >/dev/null 2>&1
}

# 1. shared files replaced
U="$T/u1"; N="$T/n1"; make_user "$U"; make_upstream "$N" 0.2.0
out="$(cd "$U" && bash scripts/update-shared.sh --from "$N" 2>&1)"
check "shared files replaced" "claude-0.2.0|skill-0.2.0|0.2.0" "$(cat "$U/CLAUDE.md")|$(cat "$U/.claude/skills/x/SKILL.md")|$(cat "$U/VERSION")"
check "summary line printed" "updated 4 files, backed up 0, 0.1.0→0.2.0" "$(echo "$out" | tail -1)"
check "sh files stay executable" "yes" "$([ -x "$U/scripts/tool.sh" ] && echo yes || echo no)"

# 2. personal data never touched
check "athlete campaigns config never touched" "my profile|my plan|my private settings" \
  "$(cat "$U/athlete/profile.md")|$(cat "$U/campaigns/c/plan.md")|$(cat "$U/config/intervals.env")"

# 3. locally modified shared file is backed up
U="$T/u3"; N="$T/n3"; make_user "$U"; make_upstream "$N" 0.2.0
echo "my edit" > "$U/CLAUDE.md"
out="$(cd "$U" && bash scripts/update-shared.sh --from "$N" 2>&1)"
bk="$(ls -d "$U"/.backup/*/ 2>/dev/null | head -1)"
check "locally modified shared file is backed up" "my edit|claude-0.2.0" "$(cat "${bk}CLAUDE.md" 2>/dev/null)|$(cat "$U/CLAUDE.md")"
check "only the edited file was backed up" "1" "$(find "$U/.backup" -type f | wc -l | tr -d ' ')"
check "backed-up count in summary" "updated 4 files, backed up 1, 0.1.0→0.2.0" "$(echo "$out" | tail -1)"

# 3b. no checksum file: every differing file is backed up
U="$T/u3b"; N="$T/n3b"; make_user "$U"; make_upstream "$N" 0.2.0
rm "$U/config/.template-checksums"
out="$(cd "$U" && bash scripts/update-shared.sh --from "$N" 2>&1)"
check "missing checksums: differing files backed up" "backed up 4" "$(echo "$out" | tail -1 | grep -o 'backed up 4')"

# 4. protected / unsafe paths refused before anything is copied
for bad in "athlete/profile.md" "campaigns/c/plan.md" "config/intervals.env"; do
  U="$T/u4"; N="$T/n4"; make_user "$U"; make_upstream "$N" 0.2.0 "$bad"
  mkdir -p "$N/$(dirname "$bad")"; echo "evil" > "$N/$bad"
  out="$(cd "$U" && bash scripts/update-shared.sh --from "$N" 2>&1)"; rc=$?
  check "protected path in TEMPLATE_FILES is refused ($bad)" "2|yes|claude-0.1.0" \
    "$rc|$(echo "$out" | grep -q "$bad" && echo yes || echo no)|$(cat "$U/CLAUDE.md")"
done

# 5. same version no-op
U="$T/u5"; N="$T/n5"; make_user "$U"; make_upstream "$N" 0.1.0
echo "changed upstream" > "$N/CLAUDE.md"
out="$(cd "$U" && bash scripts/update-shared.sh --from "$N" 2>&1)"; rc=$?
check "same version is a no-op" "0|already up to date (0.1.0)|claude-0.1.0" "$rc|$out|$(cat "$U/CLAUDE.md")"

# 6. record-checksums
U="$T/u6"; make_upstream "$U" 0.1.0; rm "$U/scripts/tool.sh"   # one listed file missing
bash "$U/scripts/update-shared.sh" --record-checksums >/dev/null 2>&1
f="$U/config/.template-checksums"
check "record-checksums writes one line per existing shared file" "5|yes" \
  "$(wc -l < "$f" | tr -d ' ')|$(grep -q "^$(shasum -a 256 "$U/CLAUDE.md" | cut -d' ' -f1)  CLAUDE.md$" "$f" && echo yes || echo no)"

# 7. unsafe paths
for bad in "../outside.txt" "/etc/hosts"; do
  U="$T/u7"; N="$T/n7"; make_user "$U"; make_upstream "$N" 0.2.0 "$bad"
  out="$(cd "$U" && bash scripts/update-shared.sh --from "$N" 2>&1)"; rc=$?
  check "unsafe path (.. or absolute) is refused ($bad)" "2|yes|claude-0.1.0" \
    "$rc|$(echo "$out" | grep -qF -- "$bad" && echo yes || echo no)|$(cat "$U/CLAUDE.md")"
done

# 8. bypass attempts on the path guard
for pair in "dot-slash prefix is refused:./athlete/p.md" "uppercase protected folder is refused:ATHLETE/q.md" ".git path is refused:.git/hooks/x"; do
  name="${pair%%:*}"; bad="${pair#*:}"
  U="$T/u8"; N="$T/n8"; make_user "$U"; make_upstream "$N" 0.2.0 "$bad"
  mkdir -p "$N/$(dirname "$bad")"; echo "evil" > "$N/$bad"
  out="$(cd "$U" && bash scripts/update-shared.sh --from "$N" 2>&1)"; rc=$?
  check "$name ($bad)" "2|yes|claude-0.1.0|my profile|none" \
    "$rc|$(echo "$out" | grep -qF -- "$bad" && echo yes || echo no)|$(cat "$U/CLAUDE.md")|$(cat "$U/athlete/profile.md")|$([ -e "$U/.git/hooks/x" ] && echo bad || echo none)"
done

# 9. CRLF line endings in TEMPLATE_FILES
U="$T/u9"; N="$T/n9"; make_user "$U"; make_upstream "$N" 0.2.0
sed 's/$/\r/' "$N/TEMPLATE_FILES" > "$N/TF.crlf" && mv "$N/TF.crlf" "$N/TEMPLATE_FILES"
out="$(cd "$U" && bash scripts/update-shared.sh --from "$N" 2>&1)"; rc=$?
check "crlf line endings handled" "0|claude-0.2.0" "$rc|$(cat "$U/CLAUDE.md")"

# 10. self-update with a longer upstream script
U="$T/u10"; N="$T/n10"; make_user "$U"; make_upstream "$N" 0.2.0
printf '\necho SHOULD-NOT-RUN\n' >> "$N/scripts/update-shared.sh"
out="$(cd "$U" && bash scripts/update-shared.sh --from "$N" 2>&1)"; rc=$?
check "self-update with a longer upstream script completes cleanly" "0|no|yes" \
  "$rc|$(echo "$out" | grep -q SHOULD-NOT-RUN && echo yes || echo no)|$(grep -q SHOULD-NOT-RUN "$U/scripts/update-shared.sh" && echo yes || echo no)"

# 11. a failed copy leaves no temp file behind
if [ "$(id -u)" -ne 0 ]; then   # root can read a chmod 000 file, so the copy wouldn't fail
  U="$T/u11"; N="$T/n11"; make_user "$U"; make_upstream "$N" 0.2.0
  chmod 000 "$N/CLAUDE.md"
  out="$(cd "$U" && bash scripts/update-shared.sh --from "$N" 2>&1)"; rc=$?
  chmod 644 "$N/CLAUDE.md"
  check "failed copy exits non-zero and leaves no temp file" "yes|0|claude-0.1.0" \
    "$([ "$rc" -ne 0 ] && echo yes || echo no)|$(find "$U" -name '*.new.*' | wc -l | tr -d ' ')|$(cat "$U/CLAUDE.md")"
fi

echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
