#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE_DIR="$ROOT/packages"
AUR_HELPER="${AUR_HELPER:-yay}"

install_from_list() {
  local list="$1"
  [[ -s "$list" ]] || return 0
  "$AUR_HELPER" -S --needed - < "$list"
}

if ! command -v "$AUR_HELPER" >/dev/null 2>&1; then
  echo "$AUR_HELPER is required before package restore" >&2
  echo "Install an AUR helper first, then rerun: $0" >&2
  exit 1
fi

install_from_list "$PACKAGE_DIR/native.txt"
install_from_list "$PACKAGE_DIR/aur.txt"
