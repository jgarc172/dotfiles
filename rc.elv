echo "loading module mine"
use path 
use str
fn splits {|@args| str:split $@args}
fn joins {|path| path:join $path}

fn last1 {|p|
  put (path:base $p)
}

fn last2 {|p|
  var li = [(splits '/' $p)]
  var cnt = (count $li)
  if (< $cnt 3) { put $p; return }
  str:join '/' $li[-2..]
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
  set git-status = (styled $git-status cyan bold)
  if $gm[dirty] {
    set git-status = (styled $git-status red bold)
  }
  set git-status = (put '('$git-status')')
 }
 put $git-status
}

var start = (styled 'λ ' green)
var end = (styled ' > ' green)
#fn dir  { last1 $pwd }
#fn dir  { last2 (tilde-abbr $pwd) }

fn last {|n p|
  var li = [(splits '/' $p)]
  var cnt = (count $li)
  if (< $cnt (+ $n 1)) { put $p; return }
  str:join '/' $li[-$n..]
}

fn dir  { 
  var abbr = (tilde-abbr $pwd)
  var first = $abbr[0]
  var last = (last 3 $abbr)
  if (eq $first $last[0]) { put $abbr; return }
  put $first'../'(last 2 $last) 
}

fn prom { 
  put $start (styled (dir) yellow bold)' '; put (git-status) $end 
}

fn rprom {
  put (git-status)
}

set edit:prompt = { prom }
set edit:rprompt = { }