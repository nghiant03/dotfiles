export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

export CARGO_HOME="$XDG_DATA_HOME/cargo"
export CODEX_HOME="$XDG_DATA_HOME/codex"
export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export DOTNET_CLI_HOME="$XDG_DATA_HOME/dotnet"
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME/jupyter"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NUGET_PACKAGES="$XDG_CACHE_HOME/NuGetPackages"
export ZSH="$XDG_DATA_HOME/oh-my-zsh"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export TEXMFVAR="$XDG_CACHE_HOME/texlive/texmf-var"
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export KAGGLE_CONFIG_DIR="$XDG_CONFIG_HOME/kaggle"
export GOPATH="$XDG_DATA_HOME/go"

if [ -f "$HOME/.secret" ]; then
  source "$HOME/.secret"
fi

# uv
export PATH="/home/nghiant/.local/share/../bin:$PATH"
