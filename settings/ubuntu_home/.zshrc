# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="gentoo"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Uncomment this to disable bi-weekly auto-update checks
DISABLE_AUTO_UPDATE="true"

# Uncomment to change how often before auto-updates occur? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want to disable command autocorrection
# DISABLE_CORRECTION="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Uncomment following line if you want to disable marking untracked files under
# VCS as dirty. This makes repository status check for large repositories much,
# much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# config Ctrl+U to delete from cursor to the beginning of line, to mimic bash behavior
bindkey \^u backward-kill-line

# configuration for zsh-completions
fpath=(~/.oh-my-zsh/custom/plugins/zsh-completions/src/ $fpath)

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git fasd tmux zsh-syntax-highlighting golang docker repo pip git-extras colored-man)
export ZSH_TMUX_AUTOSTART=true
export ZSH_TMUX_AUTOSTART_ONCE=true
export ZSH_TMUX_AUTOCONNECT=false
export ZSH_TMUX_AUTOQUIT=false

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
#PROMPT='%(!.%{$fg_bold[red]%}.%{$fg_bold[green]%}%n@)%m%{$fg_bold[blue]%}:%1d $(git_prompt_info)%_$(prompt_char)%{$reset_color%} '
PROMPT='%(!.%{$fg_bold[red]%}.%{$fg_bold[green]%}%n@)%m%{$fg_bold[blue]%}:%1d %{$fg_bold[magenta]%}$(git_prompt_info)%{$fg_bold[blue]%}$(prompt_char)%{$reset_color%} '
if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

# my own git_prompt_info function that does parse git directory status
function git_prompt_info() {
  ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
  echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$ZSH_THEME_GIT_PROMPT_SUFFIX"
}

# setup machine specific environment variables sotred in .env
if [ -f ~/.env ] ; then
    . ~/.env
fi

