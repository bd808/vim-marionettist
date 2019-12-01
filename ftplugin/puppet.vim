" marionettist.vim : some stuff to make vim + Puppet more fun
" Copyright 2019 Bryan Davis <bd808@bd808.com> and contributors
" license: GPL-3.0-or-later

" Has this already been loaded?
if exists("b:loaded_marionettist") || &cp
    finish
endif
let b:loaded_marionettist = 1

" Add `:` to filename characters so that <cfile> will match module names
setlocal isfname+=:

" map <E> in normal mode to run Marionettist_LoadFile with <cfile> as input
nnoremap <buffer> E :call Marionettist_LoadFile(expand("<cfile>"))<CR>

" make ":E foo" call Marionettist_LoadFile as well
command -nargs=1 E call Marionettist_LoadFile(<f-args>)

" TODO: optionally grab `gf` mappings too for folks who aren't used to my
" weird mapping habit

" vim: set sw=2 ts=2 sts=2 et :
