scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

" default_def {{{
" May でぼける悲しみ.
"   \ ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
let s:default_defs = {
\ '-' : [
    \ ['true', 'false'],
    \ ['on', 'off'],
    \ ['enable', 'disable'],
    \ ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
    \ ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    \ ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
    \],
\ 'tex' : [
    \ { 'cyclic': 0,
      \ 'def' : ['tiny', 'scriptsize', 'footnotesize', 'small', 'normalsize', 'large', 'Large', 'LARGE', 'huge', 'Huge'],
    \},
    \ ['\alpha', '\beta', '\gamma', '\delta', '\epsilon', '\zeta', '\eta', '\theta', '\iota', '\kappa', '\lambda', '\mu', '\nu', '\xi', '\pi', '\rho', '\sigma', '\tau', '\upsilon', '\phi', '\chi', '\psi', '\omega'],
    \ ['leftarrow', 'Leftarrow', 'longleftarrow', 'Longleftarrow'],
    \ ['longrightarrow', 'Longrightarrow', 'rightarrow', 'Rightarrow'],
    \ ['itemize', 'enumerate', 'description'],
    \ ['\begin', '\end'],
    \ ['{equation}', '{equation*}'],
    \ ['{eqnarray}', '{eqnarray*}'],
    \ ['{align}', '{align*}'],
    \ ['\cite{', '\ref{'],
    \ { 'cyclic': 0,
      \ 'def' : ['\!', '\,', '\>', '\;', '\ ', 'quad', 'qquad'],
    \},
    \],
\ 'python' : [
    \ ['True', 'False'],
    \ ['and', 'or'],
    \],
\ 'c' : [
    \ ['&&', '||'],
    \ [ {'pattern': '\(\k\+\)\.', 'replace': '\1.'},
    \   {'pattern': '\(\k\+\)->', 'replace': '\1->'}],
    \],
\}
" }}}

function! s:escape(pattern) abort " {{{
    return escape(a:pattern, '\~ .*^[''$')
endfunction " }}}

function! s:getdefs() abort " {{{
  if has_key(g:, 'clurin#config') && type(g:clurin#config) == type({})
    let p = [g:clurin#config, s:default_defs]
  else
    let p = [s:default_defs]
  endif

  let defs = []
  for d in p
    for ft in [&filetype, '-']
      if has_key(d, ft)
        call extend(defs, d[ft])
      endif
    endfor
  endfor

  return defs
endfunction " }}}

let s:no_match = {}

function! s:is_nomatch(m) abort " {{{
  return a:m == s:no_match
endfunction " }}}

function! s:match(conf) abort " {{{
  let col = col('.') - 1
  let line = getline('.')
  for i in range(len(a:conf.def))
    let d = a:conf.def[i]
    let l1 = -1
    while 1
      let l1 = match(line, d.pattern, l1)
      if l1 < 0 || l1 > col
        break
      endif
      let l2 = matchend(line, d.pattern, l1)
      if col < l2
        let text = substitute(line[l1 : l2-1], d.pattern, '\=submatch(1)', '')
        return {'start': l1, 'end': l2, 'len': l2-l1, 'index': i, 'conf': a:conf, 'text': text}
      endif
      let l1 += 1
    endwhile
  endfor
  return s:no_match
endfunction " }}}

function! s:mod(a, b) abort " {{{
  let a = a:a
  if a < 0
    while a < 0
      let a += a:b
    endwhile
    return a - a:b
  else
    while a >= a:b
      let a -= a:b
    endwhile
    return a
  endif
endfunction " }}}

function! s:replace(m, cnt, rev) abort " {{{
  if a:rev
    let idx = a:m.index - a:cnt
  else
    let idx = a:m.index + a:cnt
  endif
  if get(a:m.conf, 'cyclic', 1)
    let idx = s:mod(idx, len(a:m.conf.def))
  elseif idx < 0
    let idx = 0
  elseif idx >= len(a:m.conf.def)
    let idx = len(a:m.conf.def) - 1
  endif

  let d = a:m.conf.def[idx]
  let str = substitute(d.replace, '\\1', a:m.text, 'g')
  let line = getline('.')
  let pre = a:m.start < 1 ? '' : line[: a:m.start - 1]
  let line = pre . str . line[a:m.end :]
  call setline('.', line)
endfunction " }}}

function! s:def_normalize(d) abort " {{{
  if type(a:d) == type({})
    if !has_key(a:d, 'def')
      return {}
    endif
    let a:d.def = map(a:d.def, 's:def_normalize_elm(v:val)')
    return a:d
  elseif type(a:d) == type([])
    return {'def' : map(a:d, 's:def_normalize_elm(v:val)') }
  else
    return {}
  endif
endfunction " }}}

function! s:def_normalize_elm(d) abort " {{{
  if type(a:d) == type('')
    if a:d =~# '^\k\+$'
      return {'pattern': printf('\<\(%s\)\>', s:escape(a:d)), 'replace': a:d}
    else
      return {'pattern': printf('\(%s\)', s:escape(a:d)), 'replace': a:d}
    endif
  else
    return a:d
  endif
endfunction " }}}

function! s:cmp_match(m1, m2) abort " {{{
  if s:is_nomatch(a:m1)
    return 1
  elseif  s:is_nomatch(a:m2)
    return -1
  endif

  if a:m1.start != a:m2.start
    " なるべくカーソル側
    return a:m2.start - a:m1.start
  else
    " なるべく小さいもの. 大きい物はカーソルを移動すれば対象になる
    return a:m1.end - a:m2.end
  endif
endfunction " }}}

function! clurin#pa(cnt, rev) abort " {{{
  silent! normal! zO

  let defs = s:getdefs()
  let mb = s:no_match
  for d in defs
    let dm = s:def_normalize(d)
    let m = s:match(dm)
    if s:cmp_match(mb, m) > 0
      let mb = m
    endif
    unlet d
  endfor

  if s:is_nomatch(mb)
    return 0
  endif

"  let g:clurin#matchdef = mb " @debug
  call s:replace(mb, a:cnt, a:rev)

  silent! call repeat#set(printf(":call clurin#pa(%d,%d)\<CR>", a:cnt, a:rev))
  return 1
endfunction " }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
