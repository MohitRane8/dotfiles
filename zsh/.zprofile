# XDG Paths
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share

# tmux config dir
export TMUXDOTDIR=$HOME/.config/tmux

# zsh config dir
export ZDOTDIR=$HOME/.config/zsh

# Windows user name and directory
if [[ -n "$WSL_DISTRO_NAME" ]]; then
    WINUSERNAME=$(powershell.exe -c '$env:UserName' | tr -d '\r')
    WINUSERDIR="/mnt/c/Users/$WINUSERNAME"
fi

