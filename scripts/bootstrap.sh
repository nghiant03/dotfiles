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

install_packages() {
  "$ROOT/scripts/install-packages.sh"
}

export_packages() {
  "$ROOT/scripts/export-packages.sh"
}

install_package_hook() {
  local target_user="${2:-${SUDO_USER:-}}"
  if [[ -z "$target_user" || "$target_user" == root ]]; then
    target_user="$(stat -c %U "$ROOT")"
  fi
  "$ROOT/scripts/install-package-export-hook.sh" "$target_user" "$ROOT"
}

install_root_backintime() {
  local source="$ROOT/backintime/root-config"
  if [[ ! -e "$source" ]]; then
    echo "root Back In Time config is missing at $source" >&2
    exit 1
  fi
  if [[ $EUID -eq 0 ]]; then
    mkdir -p /root/.config/backintime
    ln -sfn "$source" /root/.config/backintime/config
  else
    echo "Run as root to link /root/.config/backintime/config" >&2
    exit 1
  fi
}

link_configs() {
  mkdir -p "$HOME/.config"
  local paths=(
    autostart
    backintime
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
    kdeglobals
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
}

install_system_zsh() {
  local zshenv_source="$ROOT/zsh/system-zshenv"
  local zprofile_source="$ROOT/zsh/system-zprofile"
  if [[ ! -e "$zshenv_source" || ! -e "$zprofile_source" ]]; then
    echo "system zsh files are missing" >&2
    exit 1
  fi
  if [[ $EUID -eq 0 ]]; then
    mkdir -p /etc/zsh
    ln -sfn "$zshenv_source" /etc/zsh/zshenv
    ln -sfn "$zprofile_source" /etc/zsh/zprofile
  else
    echo "Run as root to link /etc/zsh/zshenv and /etc/zsh/zprofile" >&2
  fi
}

usage() {
  cat <<'USAGE'
Usage: scripts/bootstrap.sh [all|packages|link|system-zsh|root-backintime|package-hook|export-packages]

Run after creating the user in Arch install:
  scripts/bootstrap.sh packages
  scripts/bootstrap.sh link
  su -c 'scripts/bootstrap.sh system-zsh'
  su -c 'scripts/bootstrap.sh root-backintime'
USAGE
}

case "${1:-all}" in
  all)
    install_packages
    link_configs
    install_system_zsh
    ;;
  packages) install_packages ;;
  link) link_configs ;;
  system-zsh) install_system_zsh ;;
  root-backintime) install_root_backintime ;;
  package-hook) install_package_hook "$@" ;;
  export-packages) export_packages ;;
  *) usage; exit 1 ;;
esac
