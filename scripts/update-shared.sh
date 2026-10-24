#!/usr/bin/env bash
# Updates the shared coaching files from a downloaded copy of the template.
# Never touches athlete/, campaigns/ or config/ (your personal data).
#
# Usage:
#   update-shared.sh --from <dir>       copy the shared files listed in <dir>/TEMPLATE_FILES
#                                       into this folder, backing up any you have edited
#   update-shared.sh --record-checksums remember what the shared files look like now, so
#                                       later updates can tell which ones you edited
#
# Plain bash only (no jq). Works on macOS bash 3.2. Makes no network calls.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SUMS="$ROOT/config/.template-checksums"

sha() { shasum -a 256 "$1" | cut -d' ' -f1; }

list_paths() { # print non-empty paths from a TEMPLATE_FILES file
  tr -d '\r' < "$1" | grep -v '^[[:space:]]*$' | grep -v '^[[:space:]]*#' || true
}

record_checksums() {
  local p tmp
  [ -f "$ROOT/TEMPLATE_FILES" ] || { echo "no TEMPLATE_FILES in $ROOT" >&2; exit 1; }
  mkdir -p "$ROOT/config"
  tmp="$(mktemp)"
  while IFS= read -r p; do
    [ -f "$ROOT/$p" ] || continue
    printf '%s  %s\n' "$(sha "$ROOT/$p")" "$p" >> "$tmp"
  done < <(list_paths "$ROOT/TEMPLATE_FILES")
  mv "$tmp" "$SUMS"
}

recorded_sum() { # path -> recorded checksum or empty
  [ -f "$SUMS" ] || return 0
  grep -F -- "  $1" "$SUMS" | grep -- "  $1\$" | head -1 | cut -d' ' -f1 || true
}

check_path() { # exit 2 unless $1 is a safe, shared (non-personal) relative path
  local p="$1" lc seg bad=0 IFS_OLD="$IFS"
  printf '%s' "$p" | grep -Eq '^[A-Za-z0-9_.-]+(/[A-Za-z0-9_.-]+)*$' || bad=1
  if [ "$bad" -eq 0 ]; then
    IFS=/; for seg in $p; do
      case "$seg" in .|..|"") bad=1 ;; esac
    done; IFS="$IFS_OLD"
    lc="$(printf '%s' "$p" | tr 'A-Z' 'a-z')"
    case "$lc" in
      athlete/*|campaigns/*|config/*|.git/*|.backup/*|.git) bad=1 ;;
    esac
  fi
  if [ "$bad" -eq 1 ]; then
    echo "refusing to update protected or unsafe path: $p" >&2; exit 2
  fi
}

install_file() { # copy $1 to $2 via a temp file + mv, so the target gets a new inode
  local tmp
  tmp="$(mktemp "$2.new.XXXXXX")"
  cp -p "$1" "$tmp"
  case "$2" in *.sh) chmod +x "$tmp" ;; esac
  mv -f "$tmp" "$2"
}

update_from() {
  local src="$1" p old new stamp bk n_updated=0 n_backed=0 have_sums=0 cur rec
  [ -f "$src/TEMPLATE_FILES" ] && [ -f "$src/VERSION" ] || {
    echo "$src does not look like the coaching template (no TEMPLATE_FILES or VERSION)" >&2; exit 1; }
  new="$(tr -d '[:space:]' < "$src/VERSION")"
  old="$(tr -d '[:space:]' < "$ROOT/VERSION" 2>/dev/null || echo unknown)"

  # Validate every path before touching anything.
  while IFS= read -r p; do
    check_path "$p"
  done < <(list_paths "$src/TEMPLATE_FILES")

  if [ "$old" = "$new" ]; then echo "already up to date ($new)"; exit 0; fi

  [ -f "$SUMS" ] && have_sums=1
  stamp="$(date +%Y%m%d-%H%M%S)"
  bk="$ROOT/.backup/$stamp"

  while IFS= read -r p; do
    [ -f "$src/$p" ] || continue
    if [ -f "$ROOT/$p" ]; then
      cmp -s "$src/$p" "$ROOT/$p" && continue
      cur="$(sha "$ROOT/$p")"; rec="$(recorded_sum "$p")"
      if [ "$have_sums" -eq 0 ] || [ "$cur" != "$rec" ]; then
        mkdir -p "$bk/$(dirname "$p")"
        cp -p "$ROOT/$p" "$bk/$p"
        n_backed=$((n_backed+1))
      fi
    fi
    mkdir -p "$ROOT/$(dirname "$p")"
    install_file "$src/$p" "$ROOT/$p"
    n_updated=$((n_updated+1))
  done < <(list_paths "$src/TEMPLATE_FILES")

  record_checksums
  echo "updated $n_updated files, backed up $n_backed, $old→$new"
}

case "${1:-}" in
  --record-checksums) record_checksums ;;
  --from) [ -n "${2:-}" ] && [ -d "$2" ] || { echo "usage: update-shared.sh --from <dir>" >&2; exit 2; }
          update_from "$(cd "$2" && pwd)"; exit 0 ;;
  *) echo "usage: update-shared.sh --from <dir> | --record-checksums" >&2; exit 2 ;;
esac
