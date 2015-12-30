scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:suite = themis#suite('case')
let s:assert = themis#helper('assert')

function! s:suite.after() " {{{
  set noignorecase
endfunction " }}}

function! s:suite.case() abort " {{{
  let g:clurin = {'-': {'def': [
        \ ['TRUE', 'FALSE'],
        \ ['True', 'False']]}}
  for r in range(2)
    if r == 0
      set ignorecase
    else
      set noignorecase
    endif
    for line in [['TRUE', 'FALSE'], ['True', 'False']]
      call setline(1, line[0])
      call setpos('.', [0,1,1,0])
      execute "normal" "\<Plug>(clurin-next)"
      call s:assert.equals(getline(1), line[1], printf("line=%s, 1", string(line)))
      execute "normal" "\<Plug>(clurin-next)"
      call s:assert.equals(getline(1), line[0], printf("line=%s, 2", string(line)))
      execute "normal" "\<Plug>(clurin-prev)"
      call s:assert.equals(getline(1), line[1], printf("line=%s, 3", string(line)))
      execute "normal" "\<Plug>(clurin-prev)"
      call s:assert.equals(getline(1), line[0], printf("line=%s, 4", string(line)))
    endfor
  endfor
endfunction " }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
