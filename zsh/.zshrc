# Brew
if [[ -f "/opt/homebrew/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Keep core zsh autoloads resolvable across brew zsh upgrades
# (version-agnostic symlink; holds is-at-least, add-zsh-hook, compinit, bashcompinit, colors)
fpath=( /opt/homebrew/share/zsh/functions $fpath )

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
# zinit light zsh-users/zsh-autosuggestions
zinit light Tarrasch/zsh-autoenv

zinit ice ver"v1"
zinit light cowboyd/zsh-rust


# Add in snippets (no completion dependency)
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::dotenv
zinit snippet OMZP::command-not-found

# GCLOUD  (use $HOMEBREW_PREFIX from `brew shellenv` instead of forking `brew --prefix` twice)
source "$HOMEBREW_PREFIX/share/google-cloud-sdk/path.zsh.inc"
source "$HOMEBREW_PREFIX/share/google-cloud-sdk/completion.zsh.inc"

# fnm completion
eval "$(fnm env --use-on-cd --shell zsh)"

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# fzf-tab must be loaded after compinit
zinit light Aloxaf/fzf-tab

# Snippets WITH completions (must be after compinit)
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::helm
zinit snippet OMZP::uv

# Terraform aliases
zinit snippet OMZP::terraform

# Terraform completions (requires bashcompinit)
autoload -U +X bashcompinit && bashcompinit
complete -C terraform terraform

# Prompt with ohmypush
eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/zen.toml)"

# Keybindings
# bindkey -e
# bindkey '^p' history-search-backward
# bindkey '^n' history-search-forward
# bindkey '^[w' kill-region

# History
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt EXTENDED_HISTORY          # Timestamps in history
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicates first
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt INC_APPEND_HISTORY        # Add commands immediately to history
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicates first

# Navigation
setopt AUTO_CD
setopt AUTO_PUSHD           # cd pushes to directory stack
setopt PUSHD_IGNORE_DUPS    # No duplicates in dir stack
setopt PUSHD_MINUS          # Swap +/- meanings for stack

# Complition
setopt ALWAYS_TO_END       # Move cursor to end after completion

# Correction
setopt CORRECT             # Command correction prompts

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias l='eza -snew'
alias ls='eza -snew'
alias ll='eza -l -snew'
alias c='clear'
alias k='kubectl'
alias kx='kubectx'
alias tailscale='/Applications/Tailscale.app/Contents/MacOS/Tailscale'

## AWS
alias aws_login_dev="aws sso login --profile dev"
alias aws_ecr_login_dev="aws_login_dev && aws ecr get-login-password --profile dev --region eu-central-1| podman login --username AWS --password-stdin 502818572390.dkr.ecr.eu-central-1.amazonaws.com"
alias aws_login_devdev="aws sso login --profile devdev"
alias aws_login_prod="aws sso login --profile prod"
alias aws_login_org="aws sso login --profile org"
alias aws_login_analytics="aws sso login --profile analytics"

alias aws_login_enx_prod="aws sso login --profile enx-prod"
alias aws_login_enx_qa="aws sso login --profile enx-qa"

alias aws_login_adscale_prod="aws sso login --profile adscale-prod"

alias aws_login_all="aws_login_dev && aws_login_prod && aws_login_org && aws_login_analytics && aws_login_enx_prod && aws_login_enx_qa"

## zinit
alias zupdate='zinit update --parallel'

# DNS
alias purge_dns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
## Old Habits
alias nvm='fnm'
#alias grep='rg'
alias docker='podman'

# TS
alias get_ts="tailscale status --json | jq -r '.Peer[]?.DNSName'"

# kubernetes edit
export KUBE_EDITOR="zed --wait"

# Secrets
[[ -f ~/.secrets ]] && source ~/.secrets

# Android
export ANDROID_HOME=~/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools

# Variable
# Locale settings
export LC_TIME="en_US.UTF-8"

# Podman to docker for SAM — cache the socket path (stable per machine) instead of
# forking `podman machine inspect` (~100ms) on every shell. Run `rm` on the cache file
# below after recreating the podman machine to refresh it.
__docker_host_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/docker_host"
if [[ -r $__docker_host_cache ]]; then
  export DOCKER_HOST="$(<$__docker_host_cache)"
elif __sock=$(podman machine inspect --format '{{.ConnectionInfo.PodmanSocket.Path}}' 2>/dev/null) && [[ -n $__sock ]]; then
  export DOCKER_HOST="unix://$__sock"
  mkdir -p "${__docker_host_cache:h}" && print -r -- "$DOCKER_HOST" > "$__docker_host_cache"
fi
unset __sock __docker_host_cache

# Shell integrations (only in interactive shells)
if [[ $- == *i* ]]; then
  eval "$(fzf --zsh)"
  eval "$(zoxide init zsh)"
  alias cd='z'
fi
# Added by dbt Fusion extension (ensure dbt binary dir on PATH)
if [[ ":$PATH:" != *":/Users/omer/.local/bin:"* ]]; then
  export PATH=/Users/omer/.local/bin:"$PATH"
fi
# Added by dbt Fusion extension
alias dbtf=/Users/omer/.local/bin/dbt

eval "$(mise activate zsh)"

alias gen_password="openssl rand -base64 32 | tr -d '=+/' | cut -c1-32"

#export GITHUB_TOKEN="$(gh auth token)" || echo "gh not authenticated, run: gh auth login"

export PATH="$HOME/.local/bin:$PATH"

alias ccc="code . && claude"

export GPG_TTY=$(tty)

# Un-export FPATH: zinit exports it, which leaks a version-pinned Cellar path into
# child shells and breaks autoloads after a brew zsh upgrade. Keep fpath shell-local.
typeset +x FPATH

# Raise open-file limit (macOS defaults to 256, too low for git scans that fan
# process substitutions across many branches). Hard limit is unlimited.
ulimit -n 8192
