scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:suite = themis#suite('jump')
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

function! s:suite.jump() abort " {{{
  unlet! g:clurin

  let line = '   \begin{description}'
  let linee = substitute(line, 'begin', 'end', '')
  let linei = substitute(line, 'description', 'itemize', '')
  for j in [0,1]
    for c in range(1, 9)
      let g:clurin = {'-': {'jump': j}}
      call setline(1, line)
      call setpos('.', [0, 1, c, 0])
      execute "normal" "\<Plug>(clurin-next)"
      if j || c >= 4
        call s:assert.equals(getline(1), linee, printf('j=%d, c=%d', j, c))
      else
        call s:assert.equals(getline(1), line,  printf('j=%d, c=%d', j, c))
      endif
    endfor

    for c in range(10, 14)
      let g:clurin = {'-': {'jump': j}}
      call setline(1, line)
      call setpos('.', [0, 1, c, 0])
      execute "normal" "\<Plug>(clurin-next)"
      if j || c >= 11
        call s:assert.equals(getline(1), linei, printf('j=%d, c=%d', j, c))
      else
        call s:assert.equals(getline(1), line,  printf('j=%d, c=%d', j, c))
      endif
    endfor
  endfor

endfunction " }}}


let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
