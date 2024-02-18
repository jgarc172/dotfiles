echo 'in ~/.bashrc '
eval "$(devbox global shellenv --init-hook)"
export INPUTRC=~/.inputrc

# bash
# ALIAS
alias ll='ls -l'
alias ls="ls -aG"
alias mv="mv -i"

  # Docker
alias di="docker image"
alias dc="docker container"
alias dn="docker network"

# COLORS
export CLICOLOR=1
#LSCOLORS=ExFxBxDxCxegedabagacad
export LSCOLORS=dxFxCxDxBxegedabagaced

declare -A colors
colors["black"]="\e[0;30m"
colors["red"]="\e[0;31m"
colors["green"]="\e[0;32m"
colors["yellow"]="\e[0;33m"
colors["blue"]="\e[0;34m"
colors["magenta"]="\e[0;35m"
colors["cyan"]="\e[0;36m"
colors["white"]="\e[0;37m"

# EXPORTS
#export LSCOLORS=AxFxCxDxBxegedabagaced
##export PS1="\W\\$ "
#export GOPATH=$HOME/code/go

# Git branch in prompt.
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

export PS1=".../\W/\$(parse_git_branch)$ "

# end bash

# from zshrc

# PROMPT
git_status() {
  declare -A hdr
  changed=0
  br=$(git status --branch --porcelain=v2 2>/dev/null)
  # v2
  # type key value
  # # branch-key value
  # ? untracked-file
  # 1 . . . staged-file
  # want:
  # branch.head
  # branch.ab
  # ?
  # 1
  while read type key value; do
    if [[ "$type" == "#" ]]; then
      hdr[$key]=$value
    fi
    if [[ "$type" == "?" || "$type" == "1" ]]; then
      changed=1
    fi
  done <<< "$br"

  if [[ $hdr[branch.head] ]]; then
    br="$hdr[branch.head] $hdr[branch.ab]"
  fi
  if [[ "$changed" -gt 0 ]]; then
      br="%B%F{red}$br%f%b"
  fi
  if [[ -n $br ]]; then
    br="(%B%F{cyan}$br%f%b)"
  fi

  echo "$br"
}

# end zshrc
