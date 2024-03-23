echo 'in ~/.bashrc '
eval "$(devbox global shellenv --init-hook)"
#export INPUTRC=~/.inputrc

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

# EXPORTS
#export LSCOLORS=AxFxCxDxBxegedabagaced
##export PS1="\W\\$ "
#export GOPATH=$HOME/code/go

# Git branch in prompt.
function parse_git_branch {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

export PS1="𝑩 ../\W/\$(parse_git_branch)$ "

function git-porcelain {
    git status --branch --porcelain=v2 2>/dev/null
}

function git-branch {
  while read type key value; do
    [[ $type = "#" ]] && printf "%s %s\n" "$key" "$value"
    [[ "?1" =~ "$type" ]] && printf "%s\n" "dirty" && break 
  done
}

function git-status {
  while read key value; do
    [[ "$key" = "branch.head" ]] && status=$value
    [[ "$key" = "branch.ab" ]] && status+=" $value"
    [[ "$key" = "dirty" ]] && status+=" $key"
  done
  printf "%s" "$status"
}

function format-git {
  status="${@:1:3}"
  [[ -n "$4" ]] && status+=" red"
  printf "%s " $status
}
# end bash

# from zshrc

# PROMPT
function git_status {
  local result=$1
  declare -A git
  git["changed"]=""
  gp=$(git status --branch --porcelain=v2 2>/dev/null)
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
    echo $type
    if [[ "$type" == "#" ]]; then
      git[$key]=$value
      echo $key ${git[$key]}
    fi
    if [[ "$type" == "?" || "$type" == "1" ]]; then
      echo $type changed
      git["changed"]=1
      echo changed ${git["changed"]}
    fi
  done <<< "$gp"

  eval "$result=(${git[@]})"
}

function gs {
  gm=()
  git_status gm
  status=""
  if [[ $gm[branch.head] ]]; then
    status="${gm[branch.head]} ${gm[branch.ab]}"
  fi
  if [[ -n $status ]]; then
    status="(%B%F{cyan}$status%f%b)"
  fi
  if [[ -n $gm["changed"] ]]; then
      status="%B%F{red}$status%f%b"
  fi
  echo $status
}
# end zshrc
