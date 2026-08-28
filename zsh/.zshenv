export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

export CARGO_HOME="$XDG_DATA_HOME/cargo"
export CODEX_HOME="$XDG_DATA_HOME/codex"
export DOTNET_CLI_HOME="$XDG_DATA_HOME/dotnet"
export FSLDIR="$XDG_DATA_HOME/fsl"
export GOPATH="$XDG_DATA_HOME/go"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"
export PYSTOW_NAME="$XDG_DATA_HOME/"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export ZSH="$XDG_DATA_HOME/oh-my-zsh"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME/jupyter"
export KAGGLE_CONFIG_DIR="$XDG_CONFIG_HOME/kaggle"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export CUDA_CACHE_PATH="$XDG_CACHE_HOME/nv"
export NUGET_PACKAGES="$XDG_CACHE_HOME/NuGetPackages"
export TEXMFVAR="$XDG_CACHE_HOME/texlive/texmf-var"
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export KERAS_HOME="$XDG_STATE_HOME/keras"

if [ -f "$HOME/.secret" ]; then
  source "$HOME/.secret"
fi

# uv
export PATH="/home/nghiant/.local/share/../bin:$PATH"
