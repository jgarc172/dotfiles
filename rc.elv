use path 
use str
use platform

set notify-bg-job-success = $false
set edit:prompt-stale-threshold = .9
var gf-time = (date +%s) # last git fetch

# Aliases
var sep = $path:separator
fn splits {|@args| str:split $@args}
# end Aliases

# Platform dependent functions
fn gitfetch { 
    if $platform:is-windows {
      var last-fetch = (- (date +%s) $gf-time)
      if (> $last-fetch 180) {
        e:pwsh -c Update-GitFetch &
        set gf-time = (date +%s)
      }
    }
}
# End Platform
fn last1 {|p|
  put (path:base $p)
}

# git status as map
fn from-git {
  var git = [&]
  # All necessary captures in next line
  # ?() captues the exception in non-git repositories as $status
  # /dev/null captures stderr and silences it
  # [ ] captures multipe lines (values) as $lines: one array or $nil
  var status = ?(var lines = [(git status --branch --porcelain=v2 2>$path:dev-null)])
  if (eq $status $ok) {
    set git[dirty] = $false
    #each {|line| put $line } $lines } | each {|line|
    for line $lines {
      var type key @value = (str:split ' ' $line)
      if (eq $type '#' ) {
        set git[$key] = $value
      }
      if (or (eq $type '?') (eq $type '1')) {
        set git[dirty] = $true
      }
    }
  }
  put $git
}

fn git-status {
  var gm = (from-git)
  var git-status = ""
  if (> (count $gm) 0) { 
    var branch = (str:join ' ' $gm[branch.head])
    var ab = (str:join ' ' $gm[branch.ab])
    set git-status = (str:join ' ' [$branch $ab])
    set git-status = (styled $git-status cyan)
    if $gm[dirty] {
      set git-status = (styled $git-status red bold)
    }
    set git-status = (put '('$git-status')')
  }
  put $git-status
}

var start = (styled 'λ ' green)
var end = (styled ' > ' green)

fn last {|n p|
  var li = [(splits $sep $p)]
  var cnt = (count $li)
  if (< $cnt (+ $n 1)) { put $p; return }
  str:join $sep $li[-$n..]
}

fn dir  { 
  var abbr = (tilde-abbr $pwd)
  var first = $abbr[0]
  var last = (last 3 $abbr)
  if (eq $first $last[0]) { put $abbr; return }
  put $first'..'$sep(last 2 $last) 
}

fn prom {
  gitfetch
  var cnt = (count (dir)) 
  var gs = (git-status)
  var up = (not (eq $gs ''))
  #if (not (eq $gs '')) { set up = (printf "%"$cnt"s" ' ') }
  if $up { put (printf "%"$cnt"s" ' ')$gs"\n" }; put $start (styled (dir) yellow)' ' $end 
}

fn rprom {
  put (git-status)
}

set edit:prompt = { prom }
set edit:rprompt = { }