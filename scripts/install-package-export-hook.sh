#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: $0 <user> [dotfiles_root]" >&2
  exit 1
fi

TARGET_USER="${1:-${SUDO_USER:-}}"
if [[ -z "$TARGET_USER" ]]; then
  echo "Usage: $0 <user> [dotfiles_root]" >&2
  exit 1
fi

USER_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
if [[ -z "$USER_HOME" ]]; then
  echo "Cannot determine home for $TARGET_USER" >&2
  exit 1
fi

DOTFILES_ROOT="${2:-$USER_HOME/.config}"
WRAPPER="/usr/local/bin/dotfiles-export-packages-$TARGET_USER"
HOOK="/etc/pacman.d/hooks/95-dotfiles-export-packages-$TARGET_USER.hook"

install -d /usr/local/bin /etc/pacman.d/hooks
cat > "$WRAPPER" <<WRAPPER
#!/usr/bin/env bash
set -euo pipefail
cd "$DOTFILES_ROOT"
runuser -u "$TARGET_USER" -- "$DOTFILES_ROOT/scripts/export-packages.sh"
WRAPPER
chmod 755 "$WRAPPER"

cat > "$HOOK" <<HOOK
[Trigger]
Operation = Install
Operation = Upgrade
Operation = Remove
Type = Package
Target = *

[Action]
Description = Refresh dotfiles package manifests for $TARGET_USER
When = PostTransaction
Exec = $WRAPPER
HOOK

echo "Installed $HOOK"
