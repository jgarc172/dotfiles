# PROMPT
  
  # last command status: √ or exit-code
exit_stat="%(?.%F{green}√.%F{red}%?)%f"

  # last 2 directories in yellow 
last2="%B%F{yellow}%2~%f%b"

  # git branch
git_branch() {
  br="$(git branch --show-current 2>/dev/null)"
  if [[ -n "$br" ]]; then
      br="(%B%F{cyan}$br%f%b)"
  fi
  echo $br
}

  # prompt characters >> 
end="%F{magenta}>>%f "

precmd() {
  PROMPT="$exit_stat $last2 $(git_branch) $end "
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
