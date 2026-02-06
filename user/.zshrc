# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=1000
setopt extendedglob
unsetopt beep
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/talles/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

#portage autocomplete
autoload -U compinit promptinit
compinit
promptinit; prompt gentoo
zstyle ':completion::complete:*' use-cache 1

alias ls='eza --color=always --long --icons=always --no-time --no-user --no-permissions'

PROMPT='%F{magenta}%n@%m%f %F{blue}%~%f %'
