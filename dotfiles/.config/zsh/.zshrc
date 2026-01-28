#!/usr/bin/env zsh
bindkey -v
HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE EXTENDED_HISTORY SHARE_HISTORY INC_APPEND_HISTORY PROMPT_SUBST
setopt AUTO_CD CORRECT NOMATCH
setopt COMPLETE_ALIUSES GLOB_COMPLETE

fpath+=($HOME/.config/zsh/completions)

autoload -U compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

eval "$(starship init zsh)"

[[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -f /usr/share/zsh/plugins/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh ]] && source /usr/share/zsh/plugins/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
[[ -f /usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh ]] && source /usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

alias ls='exa --git --icons'
alias ll='exa -l --git --icons'
alias la='exa -a --git --icons'
alias lt='exa --tree --git --icons'
alias cat='bat --theme=Dracula'
alias grep='rg'
alias find='fd'
alias du='dust'
alias top='btop'
alias htop='btop'
alias man='batman'
alias vim='nvim'
alias vi='nvim'
alias nano='nvim'
alias lg='lazygit'
alias dc='docker-compose'
alias d='docker'
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'

zstyle ':zle:*' word-style standard

bindkey '^?' backward-delete-char
bindkey '^[[Z' reverse-menu-complete

if command -v tmux &> /dev/null && [[ -z "$SSH_CONNECTION" ]]; then
    [[ -z "$TMUX" ]] && tmux new-session -A -s main
fi

end() { builtin exit }

function mkcd() { mkdir -p "$1" && cd "$1" }
function cdf() { cd "$(fd -t d)" }
function mkfile() { touch "$*" }

if command -v pyenv &> /dev/null; then
    eval "$(pyenv init -)"
fi

if command -v cargo &> /dev/null; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi

if command -v go &> /dev/null; then
    export PATH="$PATH:$(go env GOPATH)/bin"
fi