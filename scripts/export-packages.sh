#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE_DIR="$ROOT/packages"
mkdir -p "$PACKAGE_DIR"

if ! command -v pacman >/dev/null 2>&1; then
  echo "pacman is required" >&2
  exit 1
fi

pacman -Qqen | sort > "$PACKAGE_DIR/native.txt"
pacman -Qqem | sort > "$PACKAGE_DIR/aur.txt"
pacman -Qqe | sort > "$PACKAGE_DIR/explicit.txt"
