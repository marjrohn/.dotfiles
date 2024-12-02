cd $HOME

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# env
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/.cargo/bin:$PATH

export EDITOR=$(which nvim)
export VISUAL=$(which nvim)

# Set the directory to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download zinit if not exists
if [ ! -d "$ZINIT_HOME" ]; then
	mkdir -p "$(dirname $ZINIT_HOME)"
	git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add theme
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# Keybindings
bindkey -v # vim-like
# bindkey -e # emacs-like

bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# History
HISTSIZE=5000
SAVEHIST=$HISTSIZE
HISTFILE=~/.zsh_history
HISTDUP=erase

setopt aliases
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completions styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' # case insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no

zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --icons --sort type $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --icons --sort type $realpath'

# Aliases
alias c=clear
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

alias l="eza --icons --sort type"
alias ls="eza --icons --sort type"
alias ld="eza --icons --sort type --only-dirs"
alias lf="eza --icons --sort type --only-files"
alias la="eza --icons --sort type --all"
alias lda="eza --icons --sort type --dirs-only --all"
alias lfa="eza --icons --sort type --dirs-files --all"
alias ll="eza --icons --sort type --long"
alias lld="eza --icons --sort type --long --only-dirs"
alias llf="eza --icons --sort type --long --only-files"
alias lla="eza --icons --sort type --long --all"
alias llda="eza --icons --sort type --long --only-dirs --all"
alias llfa="eza --icons --sort type --long --only-files --all"


alias t="eza --tree --icons --sort type -I '.git'"
alias tree="eza --tree --icons --sort type -I '.git'"
alias t1="eza --tree --icons --sort type -I '.git' -L 1"
alias t2="eza --tree --icons --sort type -I '.git' -L 2"
alias t3="eza --tree --icons --sort type -I '.git' -L 3"
alias t4="eza --tree --icons --sort type -I '.git' -L 4"
alias ta="eza --tree --icons --sort type -I '.git' --all"
alias ta1="eza --tree --icons --sort type -I '.git' --all -L 1"
alias ta2="eza --tree --icons --sort type -I '.git' --all -L 2"
alias ta3="eza --tree --icons --sort type -I '.git' --all -L 3"
alias ta4="eza --tree --icons --sort type -I '.git' --all -L 4"

# django tree
alias tdj="eza --tree --icons --sort type -I '.git|__pycache__|migrations|__init__.py' --all"

alias bat="bat --style=plain --color=always --theme=OneHalfDark"
alias bhelp="bat --style=plain --color=always --theme=OneHalfDark --language help"
alias bman="bat --style=plain --color=always --theme=OneHalfDark --language man"

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
