#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d%H%M%S)"

link_path() {
  local source="$1"
  local target="$2"
  mkdir -p "$(dirname "$target")"
  if [[ -e "$target" || -L "$target" ]]; then
    if [[ "$(readlink -f "$target" 2>/dev/null || true)" == "$(readlink -f "$source")" ]]; then
      return 0
    fi
    mkdir -p "$BACKUP_DIR/$(dirname "${target#$HOME/}")"
    mv "$target" "$BACKUP_DIR/${target#$HOME/}"
  fi
  ln -s "$source" "$target"
}

install_aur_helper() {
  local helper="${AUR_HELPER:-yay}"
  if command -v "$helper" >/dev/null 2>&1; then
    return 0
  fi
  if [[ "$helper" != yay ]]; then
    echo "$helper is not installed; install it first or unset AUR_HELPER to bootstrap yay" >&2
    exit 1
  fi
  if [[ $EUID -eq 0 ]]; then
    echo "Run as a regular user to install yay" >&2
    exit 1
  fi
  if ! command -v sudo >/dev/null 2>&1; then
    echo "sudo is required to install yay dependencies" >&2
    exit 1
  fi
  sudo pacman -S --needed base-devel git
  local build_dir
  build_dir="$(mktemp -d)"
  trap "rm -rf $(printf '%q' "$build_dir")" EXIT
  git clone https://aur.archlinux.org/yay.git "$build_dir/yay"
  (cd "$build_dir/yay" && makepkg -si --needed)
}

install_packages() {
  install_aur_helper
  "$ROOT/scripts/install-packages.sh"
}

export_packages() {
  "$ROOT/scripts/export-packages.sh"
}

install_package_hook() {
	require_root package-hook
  local target_user="${2:-${SUDO_USER:-}}"
  if [[ -z "$target_user" || "$target_user" == root ]]; then
    target_user="$(stat -c %U "$ROOT")"
  fi
  "$ROOT/scripts/install-package-export-hook.sh" "$target_user" "$ROOT"
}

require_root() {
  if [[ $EUID -eq 0 ]]; then
    return 0
  fi
  if ! command -v sudo >/dev/null 2>&1; then
    echo "sudo is required, or run as: su -c \"$BASH_SOURCE $1\"" >&2
    exit 1
  fi
  exec sudo "$BASH_SOURCE" "$1"
}

install_root_backintime() {
  require_root root-backintime
  local source="$ROOT/backintime/root-config"
  if [[ ! -e "$source" ]]; then
    echo "root Back In Time config is missing at $source" >&2
    exit 1
  fi
  mkdir -p /root/.config/backintime
  ln -sfn "$source" /root/.config/backintime/config
}

link_configs() {
  mkdir -p "$HOME/.config"
  local paths=(
    autostart
    backintime
    conda
    conky
    crush
    fcitx5
    fontconfig
    gh/config.yml
    git
    gtk-3.0
    gtk-4.0
    htop
    jj/config.toml
    kitty
    nvim
    npm
    speech-dispatcher
    vim
    zsh
    kglobalshortcutsrc
    khotkeysrc
    kwinrc
    kwinrulesrc
    kxkbrc
    kcminputrc
    kscreenlockerrc
    kactivitymanagerdrc
    kactivitymanagerd-statsrc
    plasma-org.kde.plasma.desktop-appletsrc
    plasmarc
    plasmashellrc
    systemd/user
    mimeapps.list
    user-dirs.dirs
    xsettingsd
  )
  for path in "${paths[@]}"; do
    [[ -e "$ROOT/$path" ]] && link_path "$ROOT/$path" "$HOME/.config/$path"
  done
  local config
  for config in kdeglobals okularpartrc; do
    if [[ ! -e "$HOME/.config/$config" && ! -L "$HOME/.config/$config" ]]; then
      cp "$ROOT/$config.template" "$HOME/.config/$config"
    fi
  done
}

install_system_zsh() {
  local zshenv_source="$ROOT/zsh/system-zshenv"
  local zprofile_source="$ROOT/zsh/system-zprofile"
  if [[ ! -e "$zshenv_source" || ! -e "$zprofile_source" ]]; then
    echo "system zsh files are missing" >&2
    exit 1
  fi
  require_root system-zsh
  mkdir -p /etc/zsh
  ln -sfn "$zshenv_source" /etc/zsh/zshenv
  ln -sfn "$zprofile_source" /etc/zsh/zprofile
}

usage() {
  cat <<'USAGE'
Usage: scripts/bootstrap.sh [all|aur-helper|packages|link|system-zsh|root-backintime|package-hook|export-packages]

Run after creating the user in Arch install:
  scripts/bootstrap.sh aur-helper
  scripts/bootstrap.sh packages
  scripts/bootstrap.sh link
  scripts/bootstrap.sh system-zsh
  scripts/bootstrap.sh root-backintime

USAGE
}

case "${1:-all}" in
  all)
    install_packages
    link_configs
    install_system_zsh
    ;;
  aur-helper) install_aur_helper ;;
  packages) install_packages ;;
  link) link_configs ;;
  system-zsh) install_system_zsh ;;
  root-backintime) install_root_backintime ;;
  package-hook) install_package_hook "$@" ;;
  export-packages) export_packages ;;
  *) usage; exit 1 ;;
esac
