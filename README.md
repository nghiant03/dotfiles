# dotfiles

Personal configuration files managed with git.

## Structure

```
.
├── autostart/                  # XDG/KDE startup applications
├── backintime/
│   ├── config                  # User Back In Time profile
│   └── root-config             # /root/.config/backintime/config content
├── conky/
│   └── conky.conf              # Conky system monitor config
├── crush/
│   ├── crush.json              # Crush AI assistant config
│   └── skills/
│       ├── jupyter/            # Jupyter notebook skill
│       └── ui-ux-pro-max/      # UI/UX design skill
├── git/
│   ├── config                  # Git user & settings
│   └── ignore                  # Global gitignore
├── kitty/
│   ├── current-theme.conf      # Active Kitty theme
│   ├── kitty.conf              # Kitty terminal config
│   └── kitty.conf.bak          # Kitty config backup
├── packages/
│   ├── aur.txt                 # Explicit AUR/foreign packages
│   ├── explicit.txt            # All explicit packages
│   └── native.txt              # Explicit repo packages
├── scripts/
│   ├── bootstrap.sh            # Restore packages/configs/system zsh
│   ├── export-packages.sh      # Refresh package manifests
│   └── install-packages.sh     # Install package manifests with yay
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

## Bootstrap

From the Arch install stage after creating the user:

```sh
git clone <dotfiles-repo> ~/.config
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
| **KDE**      | Global shortcuts, keyboard options, KWin tiling/window rules, panel/taskbar layout |
| **packages** | `yay`-installable repo and AUR manifests |
| **kitty**    | Themed terminal emulator               |
| **vim/nvim** | XDG-compliant editor configs           |
| **conky**    | System monitor with custom layout      |
| **backup**   | User and root Back In Time profiles    |
| **git**      | Signing key, global ignores            |
| **crush**    | AI assistant with Jupyter & UI/UX skills |
| **speech**   | Piper TTS via speech-dispatcher        |
