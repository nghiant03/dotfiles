# dotfiles

Personal Arch Linux configuration files managed with git.

## Structure

```
.
├── autostart/                  # XDG/KDE startup applications
├── backintime/
│   ├── config                  # User Back In Time profile
│   └── root-config             # /root/.config/backintime/config content
├── conky/                      # Conky system monitor config and scripts
├── crush/                      # Crush config
├── git/
│   └── config                  # Git user & settings
├── kitty/                      # Kitty terminal config and theme
├── opencode/                   # OpenCode config
├── packages/
│   ├── aur.txt                 # Explicit foreign/AUR packages
│   ├── explicit.txt            # All explicit packages
│   └── native.txt              # Explicit repo packages
├── scripts/
│   ├── bootstrap.sh            # Restore packages/configs/system zsh
│   ├── export-packages.sh      # Refresh package manifests
│   ├── install-package-export-hook.sh # Pacman post-transaction export hook
│   └── install-packages.sh     # Install package manifests with an AUR helper
├── skills/                     # Shared skills for Crush and OpenCode
├── speech-dispatcher/
│   ├── modules/piper.conf      # Piper TTS module config
│   └── speechd.conf            # Speech dispatcher config
├── vim/
│   └── vimrc                   # Vim editor config
└── zsh/
    ├── .p10k.zsh               # Powerlevel10k theme config
    ├── .zshenv                 # Zsh environment variables
    ├── .zshrc                  # Zsh shell config
    ├── system-zprofile         # /etc/zsh/zprofile content
    └── system-zshenv           # /etc/zsh/zshenv content
```

Other tracked files cover KDE/Plasma, fcitx5, GTK, fontconfig, and developer
tools.

## Bootstrap

From the Arch install stage after creating the user:

```sh
git clone <dotfiles-repo> ~/.config
~/.config/scripts/bootstrap.sh aur-helper
~/.config/scripts/bootstrap.sh packages
~/.config/scripts/bootstrap.sh link
su -c '~/.config/scripts/bootstrap.sh system-zsh'
su -c '~/.config/scripts/bootstrap.sh root-backintime'
su -c '~/.config/scripts/bootstrap.sh package-hook'
```
Refresh package manifests from the current machine:

```sh
~/.config/scripts/bootstrap.sh export-packages
```

## Details

| Component    | Key highlights                          |
|--------------|-----------------------------------------|
| **zsh**      | Powerlevel10k prompt, XDG directory compliance |
| **KDE**      | Global shortcuts, keyboard options, KWin window rules, Plasma settings |
| **packages** | Explicit native and foreign/AUR manifests; optional automatic export hook |
| **kitty**    | Themed terminal emulator               |
| **vim**      | Editor config                          |
| **conky**    | System monitor with custom layout      |
| **backup**   | User and root Back In Time profiles    |
| **git**      | Signing and editor settings            |
| **OpenCode** | AI assistant with plugins, presets, and skills |
| **crush**    | Shared AI skills linked from `skills/` |
| **speech**   | Piper TTS via speech-dispatcher        |
