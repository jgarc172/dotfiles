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

# Git branch in prompt.
function parse_git_branch {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

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
  local status
  while read key value; do
    [[ "$key" = "branch.head" ]] && status=$value
    [[ "$key" = "branch.ab" ]] && status+=" $value"
    [[ "$key" = "dirty" ]] && status+=" $key"
  done
  printf "%s" "$status"
}

function format-git {
  status="${@:1:3}"
  dirty=$4
  color="cyan"
  [[ -n "$dirty" ]] && color="red"
  status=$(color "$status" $color)
  printf "%s" "$status"
}

function color {
  local string=$1
  local color=$2
  local reset="\e[0m"
  local code="\e[39m"

  case ${color} in
    red)
      code="\e[31m";;
    cyan)
      code="\e[36m";;
    *)
      code=$code;;
  esac
  printf "%s" "\[${code}\]${string}\[${reset}\]"
}

function branch-status {
  git-porcelain | git-branch | git-status
}

# EXPORTS
#export LSCOLORS=AxFxCxDxBxegedabagaced
##export PS1="\W\\$ "
#export GOPATH=$HOME/code/go

# COLORS
export CLICOLOR=1
#LSCOLORS=ExFxBxDxCxegedabagacad
export LSCOLORS=dxFxCxDxBxegedabagaced

function prompt {
  stat=$(branch-status)
  if [[ "$stat" ]]; then
    stat="($(format-git $stat))"
    stat="           ${stat}\n"
  fi
  PS1="${stat}𝑩 ../\W/ $ "
}

#export PS1="𝑩 ../\W/\$(parse_git_branch)$ "
#export PS1="𝑩 ../\W/ \$(echo -e \$(prompt-status))$ "
#export PS1="$(prompt-status)𝑩 ../\W/ $ "
PROMPT_COMMAND=prompt