scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:suite = themis#suite('pa')
let s:assert = themis#helper('assert')

let s:debug = 1

function! s:suite.before()
  let s:lines = [
        \ "1 2 3 4 5 6 7 8 9 10",
        \ "true false true false",
        \ "Sun Mon Tue",
        \]
  lockvar s:lines
  nmap + <Plug>(clurin-next)
  nmap - <Plug>(clurin-prev)
endfunction

function! s:suite.before_each()
  new
  call append(1, s:lines)
  1 delete _
endfunction

function! s:suite.after_each()
  quit!
endfunction

function! s:suite.truefalse()
  let g:clurin#config = {'-': {'def': [['true', 'false']]}}
  let line = s:lines[1]
  for cnt in ['','1','2','3']
    for typ in ['+', '-']
      for i in range(1, len(s:lines[1]))
        call setline(2, line)
        call setpos('.', [0, 2, i, 0])
        if typ == '+'
          execute "normal" cnt . "\<Plug>(clurin-next)"
        else
          execute "normal" cnt . "\<Plug>(clurin-prev)"
        endif
        if line[i-1] ==# ' ' || cnt ==# '2'
          let exp = line
        elseif i <= 4 
          let exp = substitute(line, 'true', 'false', '')
        elseif i <= 10
          let exp = substitute(line, 'false', 'true', '')
        elseif i <= 15
          let exp = substitute(line, ' true', ' false', '')
        else
          let exp = substitute(line, 'false$', 'true', '')
        endif

        call s:assert.equals(getline(2), exp, printf("%s %s", typ, string(getpos('.'))))
      endfor
    endfor
  endfor
endfunction

call themis#func_alias({'test.pa.s:suit': s:suite})
call themis#func_alias({'test.pa.s:': s:})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
