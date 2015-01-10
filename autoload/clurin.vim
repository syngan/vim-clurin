scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:default_defs = {
\ '-' : [
    \ ['true', 'false'],
    \ ['Jan', 'Feb', 'Mar', 'Apl', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
    \ ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    \],
\ 'tex' : [
    \ ['tiny', 'scriptsize', 'footnotesize', 'small', 'normalsize', 'large', 'Large', 'LARGE', 'huge', 'Huge'],
    \ ['alpha', 'beta', 'gamma', 'delta', 'epsilon', 'zeta', 'eta', 'theta', 'iota', 'kappa', 'lambda', 'mu', 'nu', 'xi', 'pi', 'rho', 'sigma', 'tau', 'upsilon', 'phi', 'chi', 'psi', 'omega'],
    \ ['leftarrow', 'Leftarrow', 'longleftarrow', 'Longleftarrow'],
    \ ['longrightarrow', 'Longrightarrow', 'rightarrow', 'Rightarrow'],
    \],
\}

function! s:getdefs() abort " {{{
  let defs = []
  call extend(defs, s:default_defs['-'])
  if has_key(s:default_defs, &filetype)
    call extend(defs, s:default_defs[&filetype])
  endif
  return defs
endfunction " }}}

let s:no_match = {}

function! s:is_nomatch(m) abort " {{{
  return a:m == s:no_match
endfunction " }}}

function! s:match(def) abort " {{{
  let col = col('.')
  let line = getline('.')
  for i in range(len(a:def))
    let d = a:def[i]
    let l1 = -1
    while 1
      let l1 = match(line, d.pattern, l1)
      if l1 < 0 || l1 > col
        break
      endif
      let l2 = matchend(line, d.pattern, l1)
      if col <= l2
        let text = substitute(line[l1 : l2], d.pattern, '\=submatch(1)', '')
        return {'start': l1, 'end': l2, 'len': l2-l1, 'index': i, 'def': a:def, 'text': text}
      endif
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
  let d = a:m.def[s:mod(idx, len(a:m.def))]
  let str = substitute(d.replace, '\\1', a:m.text, 'g')
  let line = getline('.')
  let pre = a:m.start < 1 ? '' : line[: a:m.start - 1]
  let line = pre . str . line[a:m.end :]
  call setline('.', line)
endfunction " }}}

function! s:def_normalize(d) abort " {{{
  if type(a:d) == type('')
    return {'pattern': printf('\(\<%s\>\)', a:d), 'replace': a:d}
  else
    return a:d
  endif
endfunction " }}}

function! clurin#pa(cnt, rev) abort " {{{
  silent! normal! zO

  let defs = s:getdefs()
  let mb = s:no_match
  for d in defs

    let d = map(d, 's:def_normalize(v:val)')
    let m = s:match(d)
    if !s:is_nomatch(m)
      " 前優先
      let mb = m
      break
    endif
  endfor

  if s:is_nomatch(mb)
    return 0
  endif

  call s:replace(mb, a:cnt, a:rev)

  silent! call repeat#set(printf(":call clurin#pa(%d,%d)\<CR>", a:cnt, a:rev))
  return 1
endfunction " }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
