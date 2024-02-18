# PROMPT
  
  # last command status: √ or exit-code
exit_stat="%(?.%F{green}𝑍.%F{red}%?)%f"

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

  # prompt characters >> 
end="%F{magenta}>>%f"

precmd() {
  NEWLINE=$'\n'
  gs=$(git_status)
  up=""
  if [[ ${#gs} -gt 0 ]]; then
    cnt=$((${#last2} - 5))
    up="$(printf "%"$cnt"s" ' ')${gs}${NEWLINE}"
  fi
  PROMPT="${up}$exit_stat $last2  $end "
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

# end

eval "$(devbox global shellenv --init-hook)"
