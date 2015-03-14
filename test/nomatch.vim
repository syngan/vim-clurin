scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:suite = themis#suite('nomatch')
let s:assert = themis#helper('assert')

function! s:CtrlAX(cnt) abort
	if a:cnt >= 0
		execute 'normal!' a:cnt . "\<C-A>"
	else
		execute 'normal!' (-a:cnt) . "\<C-X>"
	endif
endfunction

function! s:CtrlAX2(cnt) abort
  return s:CtrlAX(-a:cnt)
endfunction

function! s:suite.before() " {{{
endfunction " }}}

function! s:suite.before_each() " {{{
  new
  set ft=boo
endfunction " }}}

function! s:suite.after_each() " {{{
  quit!
endfunction " }}}

function! s:suite.def_ft() " {{{
  let g:clurin = {
\   '-'  : {'nomatch': function('s:CtrlAX'), 'use_default': 0},
\   'boo': {'nomatch': function('s:CtrlAX2'), 'use_default': 0},
\ }

  let str = 'hhhh 123 456 ggggg'
  for i in range(1, 3)
    call setline(1, str)
    call setpos('.', [0, 1, 1, 0])
    execute "normal" i . "\<Plug>(clurin-next)"
    let ans = substitute(str, 123, 123-i, '')
    call s:assert.equals(getline(1), ans,  printf('next,i=%d', i))

    call setpos('.', [0, 1, 1, 0])
    execute "normal" i . "\<Plug>(clurin-prev)"
    call s:assert.equals(getline(1), str,  printf('prev,i=%d', i))
  endfor
endfunction " }}}

function! s:suite.def_def() " {{{
  let g:clurin = {
\   '-'  : {'nomatch': function('s:CtrlAX'), 'use_default': 0},
\   'boo': {'use_default': 0},
\ }

  let str = 'hhhh 123 456 ggggg'
  for i in range(1, 3)
    call setline(1, str)
    call setpos('.', [0, 1, 1, 0])
    execute "normal" i . "\<Plug>(clurin-next)"
    let ans = substitute(str, 123, 123+i, '')
    call s:assert.equals(getline(1), ans,  printf('next,i=%d', i))

    call setpos('.', [0, 1, 1, 0])
    execute "normal" i . "\<Plug>(clurin-prev)"
    call s:assert.equals(getline(1), str,  printf('prev,i=%d', i))
  endfor
endfunction " }}}

call themis#func_alias({'test.nomatch.s:suit': s:suite})
call themis#func_alias({'test.nomatch.s:': s:})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
