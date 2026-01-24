# Zsh shell configuration for Arch Coding Distro
bindkey -v
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=$HOME/.zsh_history

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt PROMPT_SUBST

fpath+=($HOME/.config/zsh/completions)

autoload -U compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors ""

eval "$(starship init zsh)"

[[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -f /usr/share/zsh/plugins/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh ]] && source /usr/share/zsh/plugins/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
[[ -f /usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh ]] && source /usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh

alias ls='exa --git --icons'
alias ll='exa -l --git --icons'
alias la='exa -a --git --icons'
alias tree='exa --tree --git --icons'

alias cat='bat'
alias grep='rg'
alias find='fd'

alias vim='nvim'
alias vi='nvim'

alias lg='lazygit'
alias dc='docker-compose'
alias d='docker'

alias c='clear'

if command -v tmux &> /dev/null && [[ -z "$SSH_CONNECTION" ]]; then
    [[ -z "$TMUX" ]] && tmux new-session -A -s main
fi

end() {
    builtin exit
}