# Brew
if test -x /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv fish | source
end

fish_add_path -g --path $HOME/.cargo/bin

# Android
set -gx ANDROID_HOME $HOME/Library/Android/sdk
fish_add_path -ga --path $ANDROID_HOME/emulator $ANDROID_HOME/platform-tools

set -gx KUBE_EDITOR "zed --wait"
set -gx LC_TIME en_US.UTF-8

# Podman to docker for SAM - the socket path is cached (shared with zsh) instead of
# forking `podman machine inspect` on every shell. Delete the cache file after
# recreating the podman machine to refresh it.
set -l docker_host_cache (set -q XDG_CACHE_HOME; and echo $XDG_CACHE_HOME; or echo $HOME/.cache)/zsh/docker_host
if test -r $docker_host_cache
    set -gx DOCKER_HOST (cat $docker_host_cache)
else if set -l sock (podman machine inspect --format '{{.ConnectionInfo.PodmanSocket.Path}}' 2>/dev/null); and test -n "$sock"
    set -gx DOCKER_HOST unix://$sock
    mkdir -p (path dirname $docker_host_cache); and echo $DOCKER_HOST >$docker_host_cache
end

# Raise open-file limit (macOS defaults to 256, too low for git scans that fan
# process substitutions across many branches)
ulimit -n 8192

# After brew and cargo so mise-managed tools win over theirs
# (conf.d/mise-activate.fish disables brew's own, earlier activation)
mise activate fish | source
fish_add_path -g --path $HOME/.local/bin

# Everything below must not leak into non-interactive shells (scripts,
# Claude Code's Bash tool) where eza/zoxide flags break things
status is-interactive; or return

set -gx GPG_TTY (tty)
set -g fish_greeting

# Prompt: functions/fish_prompt.fish
set -g __fish_git_prompt_showdirtystate 1
set -g __fish_git_prompt_showupstream auto
set -g __fish_git_prompt_char_dirtystate ✗
set -g __fish_git_prompt_char_stagedstate +
set -g __fish_git_prompt_char_upstream_ahead ⇡
set -g __fish_git_prompt_char_upstream_behind ⇣
set -g __fish_git_prompt_char_upstream_equal ''
set -g __fish_git_prompt_char_stateseparator ''
set -g __fish_git_prompt_color_branch red --bold
set -g __fish_git_prompt_color_dirtystate yellow
set -g __fish_git_prompt_color_stagedstate green
set -g __fish_git_prompt_color_upstream cyan

fzf --fish | source
zoxide init fish --cmd cd | source

alias l='eza -snew'
alias ls='eza -snew'
alias ll='eza -l -snew'

abbr -a c clear
abbr -a k kubectl
abbr -a kx kubie ctx
alias tailscale='/Applications/Tailscale.app/Contents/MacOS/Tailscale'
alias docker='podman'
abbr -a ccc 'code . && claude'
alias gen_password="openssl rand -base64 32 | tr -d '=+/' | cut -c1-32"
alias purge_dns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
alias get_ts="tailscale status --json | jq -r '.Peer[]?.DNSName'"

## AWS - one login per SSO session covers every profile on it
alias aws_login_xpend='aws sso login --sso-session xpand'
alias aws_login_enx='aws sso login --sso-session enx'
alias aws_login_adscale='aws sso login --sso-session adscale'
alias aws_login_all='aws_login_xpend && aws_login_enx && aws_login_adscale'
alias aws_ecr_login_dev='aws_login_xpend && aws ecr get-login-password --profile dev --region eu-central-1 | podman login --username AWS --password-stdin 502818572390.dkr.ecr.eu-central-1.amazonaws.com'
alias aws_ecr_login_enx_dev='aws_login_enx && aws ecr get-login-password --profile enx-dev --region eu-west-1 | podman login --username AWS --password-stdin 241533118296.dkr.ecr.eu-west-1.amazonaws.com'
