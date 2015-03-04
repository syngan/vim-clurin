scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:suite = themis#suite('tex')
let s:assert = themis#helper('assert')

function! s:suite.before() " {{{
endfunction " }}}

function! s:suite.before_each() " {{{
  new
  set ft=tex
endfunction " }}}

function! s:suite.after_each() " {{{
  quit!
endfunction " }}}

function! s:suite.bib() " {{{
  unlet! g:clurin#config
  let bib = ['plain', 'alpha', 'abbrv', 'unstr']
  for pre in ['', 'j']
    call setline(1, printf('{%s%s}', pre, bib[0]))
    for i in range(len(bib)-1)
      call setpos('.', [0, 1, 1, 0])
      execute "normal" "\<Plug>(clurin-next)"
      call s:assert.equals(getline(1), printf('{%s%s}', pre, bib[i+1]), printf('pre=%s,i=%d', pre, i))
    endfor
  endfor
endfunction " }}}

function! s:suite.fontsize() " {{{
  " non cyclic
  unlet! g:clurin#config
  let size =  ['\tiny', '\scriptsize', '\footnotesize', '\small', '\normalsize', '\large', '\Large', '\LARGE', '\huge', '\Huge']
  for i in range(len(size))
    call setline(1, size[i])
    call setpos('.', [0, 1, 1, 0])
    execute "normal" "\<Plug>(clurin-prev)"
    let j = i==0 ? 0 : i-1
    call s:assert.equals(getline(1), size[j], printf('prev,i=%d, j=%d', i, j))
    call setpos('.', [0, 1, 1, 0])
    call setline(1, size[i])
    execute "normal" "\<Plug>(clurin-next)"
    let j = i+1 < len(size) ? i+1 : i
    call s:assert.equals(getline(1), size[j], printf('next,i=%d, j=%d', i, j))
  endfor
endfunction " }}}

call themis#func_alias({'test.tex.s:suit': s:suite})
call themis#func_alias({'test.tex.s:': s:})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
