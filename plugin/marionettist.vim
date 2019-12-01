" marionettist.vim : some stuff to make vim + Puppet more fun
" Copyright 2019 Bryan Davis <bd808@bd808.com> and contributors
"
" This program is free software: you can redistribute it and/or modify
" it under the terms of the GNU General Public License as published by
" the Free Software Foundation, either version 3 of the License, or
" (at your option) any later version.
"
" This program is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
" GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with this program.  If not, see <https://www.gnu.org/licenses/>.

" Has this already been loaded?
if exists("g:loaded_marionettist") || &cp
    finish
endif
let g:loaded_marionettist = 1
let s:keepcpo = &cpo
set cpo&vim

function! s:ModulesRoot() abort
  " TODO: allow setting a variable pointing to the modules root
  let l:cwd = expand('%:p:h')
  if l:cwd !~ "modules"
    throw "Can not find 'modules' parent directory"
  endif
  while match(l:cwd, "^.*/modules$") == -1
    let l:cwd = substitute(l:cwd, "/[^/]*$", "", "")
  endwhile
  return l:cwd
endf

function! s:ManifestToPath(name) abort
  " ::foo::bar -> foo/manifests/bar.pp
  let l:fname = substitute(trim(a:name, ":"), "::", "/", "ge")
  let l:parts = split(l:fname, "/")
  let l:whole = insert(l:parts, "manifests", 1)
  if len(l:whole) == 2
    " add default module filename
    let l:whole = add(l:whole, "init.pp")
  endif
  let l:fname = join(l:whole, "/")
  if l:fname !~ "\.pp$"
    let l:fname = l:fname . ".pp"
  endif
  return l:fname
endf

function! s:SourceToPath(name) abort
  " puppet:///modules/ferm/ferm.conf -> ferm/files/ferm.conf
  let l:prefix = "puppet:///modules"
  if a:name !~ "^" . l:prefix
    throw "Expected " . a:name . " to start with " . l:prefix
  endif
  let l:path = strpart(a:name, len(l:prefix))
  let l:parts = split(l:path, "/")
  let l:whole = insert(l:parts, "files", 1)
  let l:fname = join(l:whole, "/")
  return l:fname
endf

function! s:ContentToPath(name) abort
  " dynamicproxy/nginx.conf -> dynamicproxy/templates/nginx.conf
  let l:parts = split(a:name, "/")
  let l:whole = insert(l:parts, "templates", 1)
  let l:fname = join(l:whole, "/")
  return l:fname
endf

function! Marionettist_LoadFile(cfile) abort
  let l:oldpath = &path
  let lookups = ['s:SourceToPath', 's:ContentToPath', 's:ManifestToPath']
  let l:mroot = s:ModulesRoot()

  for lookup in lookups
    try
      let &path = l:mroot . '/**'
      execute "find " . call(lookup, [a:cfile])
      return
    catch /.*/
      " ignored
    finally
      let &path = l:oldpath
    endtry
  endfor
endf

let &cpo = s:keepcpo
unlet s:keepcpo
" vim: set sw=2 ts=2 sts=2 et :
