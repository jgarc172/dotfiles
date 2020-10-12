# PROMPT
  
  # last command status: √ or exit-code
exit_stat="%(?.%F{green}√.%F{red}%?)%f"

  # last 2 directories in yellow 
last2="%B%F{yellow}%2~%f%b"

  # git branch
git_branch() {
  br="$(git branch --show-current 2>/dev/null)"
  if [[ -n "$br" ]]; then
    if [[ $(git status --porcelain) ]]; then
      br="(%B%F{red}$br%f%b)"
    else
      br="(%B%F{cyan}$br%f%b)"
    fi
  fi
  echo $br
}

git_status() {
  declare -A hdr
  br=$(git status --branch --porcelain=v2)
  # v2
  # # branch-key value
  # ? modified-file
  # want:
  # branch.head
  # branch.ab
  # ?
  while read type key value; do
    if [[ "$type" == "#" ]]; then
      hdr[$key]=$value
    fi
    if [[ "$type" == "?" ]]; then
      untracked=1
    fi
  done <<< "$br"

  br="$hdr[branch.head] $hdr[branch.ab]"
  if [[ $untracked ]]; then
      br="%B%F{red}$br%f%b"
    else
      br="%B%F{cyan}$br%f%b"
  fi
  if [[ $br ]]; then
    br="($br)"
  fi

  echo "$br"
}

  # prompt characters >> 
end="%F{magenta}>>%f"

precmd() {
  PROMPT="$exit_stat $last2 $(git_status) $end "
}

# ALIASES

alias ls="ls -aG"
alias ll="ls -l"
alias mv="mv -i"

  # Docker
alias di="docker image"
alias dc="docker container"
alias dn="docker network"

# COLORS

export CLICOLOR=1
#LSCOLORS=ExFxBxDxCxegedabagacad
export LSCOLORS=dxFxCxDxBxegedabagaced
