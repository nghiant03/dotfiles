# Scripts

- `export-packages.sh`: refreshes package manifests from the current Arch system.
- `install-packages.sh`: restores repo and AUR packages using `yay` or `$AUR_HELPER`.
- `install-package-export-hook.sh`: installs a pacman hook that refreshes package manifests after package changes.
- `bootstrap.sh`: installs `yay` when needed, runs package restore, config symlinks, package-list hook setup, system zsh setup, and root Back In Time config linking.

Fresh install sequence after user creation:

```sh
git clone <dotfiles-repo> ~/.config
~/.config/scripts/bootstrap.sh aur-helper
~/.config/scripts/bootstrap.sh packages
~/.config/scripts/bootstrap.sh link
su -c '~/.config/scripts/bootstrap.sh system-zsh'
su -c '~/.config/scripts/bootstrap.sh root-backintime'
su -c '~/.config/scripts/bootstrap.sh package-hook'
```

Refresh package lists on this machine:

```sh
~/.config/scripts/bootstrap.sh export-packages
```
