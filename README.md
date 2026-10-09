# dotfiles

Personal Arch Linux configuration files managed with git.

## Structure

```
.
├── agents/
│   └── skills/                 # Skills for coding harness
├── autostart/                  # XDG/KDE startup applications
├── backintime/
│   ├── config                  # User Back In Time profile
│   └── root-config             # /root/.config/backintime/config content
├── conky/                      # Conky system monitor config and scripts
├── crush/                      # Crush config
├── fcitx5/                     # Input method 
├── git/
│   └── config                  # Git user & settings
├── jj/config.toml              # Jujutsu VCS settings
├── jupyter/                    # JupyterLab config and user settings
├── keepassxc/keepassxc.ini     # Password manager settings
├── kitty/                      # Kitty terminal config and theme
├── nvim/                       # Neovim config
├── opencode/                   # OpenCode config and skills
├── packages/
│   ├── aur.txt                 # Explicit foreign/AUR packages
│   ├── explicit.txt            # All explicit packages
│   └── native.txt              # Explicit repo packages
├── scripts/
│   ├── bootstrap.sh            # Restore packages/configs/system zsh
│   ├── export-packages.sh      # Refresh package manifests
│   ├── install-package-export-hook.sh # Pacman post-transaction export hook
│   └── install-packages.sh     # Install package manifests with an AUR helper
├── starship.toml               # Shell prompt
├── systemd/user/               # User units (ssh-agent, power-profile)
├── user-dirs.dirs              # XDG user directories
├── vesktop/                    # Vesktop (Discord) settings and quick CSS
├── vim/
│   └── vimrc                   # Vim editor config
├── xsettingsd/xsettingsd.conf  # GTK settings without full GNOME stack
└── zsh/
    ├── .zshenv                 # Zsh environment variables
    ├── .zshrc                  # Zsh shell config
    ├── system-zprofile         # /etc/zsh/zprofile content
    └── system-zshenv           # /etc/zsh/zshenv content
```

Other tracked files cover the KDE/Plasma rc files (`kwinrc`, `dolphinrc`,
`konsolerc`, `kdedefaults/`, ...) and GTK 3/4 theme assets.

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
| **zsh**      | Starship prompt, XDG directory compliance |
| **KDE**      | Global shortcuts, keyboard options, KWin window rules, Plasma settings |
| **packages** | Explicit native and foreign/AUR manifests; optional automatic export hook |
| **kitty**    | Themed terminal emulator               |
| **vim**      | Editor config                          |
| **conky**    | System monitor with custom layout      |
| **backup**   | User and root Back In Time profiles    |
| **git**      | Signing and editor settings            |
| **OpenCode** | AI assistant with plugins, presets, and skills |
| **crush**    | AI assistant config with hooks; skills in `agents/skills/` |
| **nvim**     | LazyVim-based editor config with plugin set |
| **speech**   | Piper TTS via speech-dispatcher        |
