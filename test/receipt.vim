scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:suite = themis#suite('receipt')
let s:assert = themis#helper('assert')

function! s:suite.before()
  let g:clurin = {
\ 'vim': {
\   'def': [[
\       {'pattern': '\[''\(\k\+\)''\]', 'replace': '[''\1'']'},
\       {'pattern': '\["\(\k\+\)"\]',   'replace': '["\1"]'},
\       {'pattern': '\.\(\k\+\)',       'replace': '.\1'},
\   ]], 'use_default': 0, 'use_default_user': 0},
\}
endfunction

function! s:suite.before_each()
  execute 'normal!' 'ggdG'
endfunction

function! s:suite.after_each()
endfunction

function! s:suite.vimdict()
  set ft=vim
  call setline(1, 'dict[''key'']')
  call setpos('.', [0, 1, 5, 0])
  execute "normal" "\<Plug>(clurin-next)"
  call s:assert.equals(getline(1), 'dict["key"]', 1)
  call setpos('.', [0, 1, 5, 0])
  execute "normal" "\<Plug>(clurin-next)"
  call s:assert.equals(getline(1), 'dict.key', 1)
  call setpos('.', [0, 1, 5, 0])
  execute "normal" "\<Plug>(clurin-next)"
  call s:assert.equals(getline(1), 'dict[''key'']', 1)
endfunction

call themis#func_alias({'test.pa.s:suit': s:suite})
call themis#func_alias({'test.pa.s:': s:})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
