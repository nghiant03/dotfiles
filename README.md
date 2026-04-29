# dotfiles

Personal configuration files managed with git.

## Structure

```
.
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
├── speech-dispatcher/
│   ├── modules/piper.conf      # Piper TTS module config
│   └── speechd.conf            # Speech dispatcher config
├── vim/
│   └── vimrc                   # Vim editor config
└── zsh/
    ├── .p10k.zsh               # Powerlevel10k theme config
    ├── .zshenv                 # Zsh environment variables
    └── .zshrc                  # Zsh shell config
```

## Details

| Component    | Key highlights                          |
|--------------|-----------------------------------------|
| **zsh**      | Powerlevel10k prompt, XDG directory compliance |
| **kitty**    | Themed terminal emulator               |
| **vim**      | XDG-compliant, syntax highlighting     |
| **conky**    | System monitor with custom layout      |
| **git**      | Signing key, global ignores            |
| **crush**    | AI assistant with Jupyter & UI/UX skills |
| **speech**   | Piper TTS via speech-dispatcher        |
