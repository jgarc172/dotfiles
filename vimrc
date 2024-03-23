" settings for Vim

syntax on
set showmode
set nohlsearch
set autoindent
set tabstop=4
set expandtab " converts tabs to spaces
set laststatus=2
set ruler
set wrap
set rnu!

"Mode Settings

let &t_SI.="\e[5 q" "SI = INSERT mode
let &t_SR.="\e[4 q" "SR = REPLACE mode
let &t_ER.="\e[1 q" "SR = REPLACE mode
let &t_EI.="\e[1 q" "EI = NORMAL mode (ELSE)

"Cursor settings:

"  1 -> blinking block
"  2 -> solid block 
"  3 -> blinking underscore
"  4 -> solid underscore
"  5 -> blinking vertical bar
"  6 -> solid vertical bar
