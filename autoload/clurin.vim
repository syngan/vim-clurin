scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! s:countup(str, cnt, ...) abort " {{{
  return str2nr(a:str) + a:cnt
endfunction " }}}

" default_def {{{
" May でぼける悲しみ.
"   \ ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
let s:default_defs = {
\ '-' : [
    \ [{'pattern': '\(-\?\d\+\)', 'replace': function('s:countup')}],
    \ ['true', 'false'],
    \ ['on', 'off'],
    \ ['enable', 'disable'],
    \ ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
    \ ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    \ ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
    \],
\ 'tex' : [
    \ { 'cyclic': 0,
      \ 'group' : ['\tiny', '\scriptsize', '\footnotesize', '\small', '\normalsize', '\large', '\Large', '\LARGE', '\huge', '\Huge'],
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
    \ ['\land', '\lor'],
    \ ['\cap', '\cup'],
    \ ['\sum', '\Sum'],
    \ ['{plain}', '{alpha}', '{abbrv}', '{unstr}'],
    \ ['{jplain}', '{jalpha}', '{jabbrv}', '{junstr}'],
    \ { 'cyclic': 0,
      \ 'group' : ['\!', '\,', '\>', '\;', '\ ', '\quad', '\qquad'],
    \},
    \],
\ 'python' : [
    \ ['True', 'False'],
    \ ['and', 'or'],
    \ ['release', 'acquire'],
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
  let p = []
  if has_key(g:, 'clurin') && type(g:clurin) == type({})
    let conf = g:clurin
  else
    let conf = s:default_defs
  endif
  let q = []
  let p = []
  for ft in [&filetype, '-']
    if has_key(conf, ft)
      call add(p, conf[ft])
      if get(conf, 'use_default', 1) && has_key(s:default_defs, ft) &&
            \ conf != s:default_defs
        call add(q, s:default_defs[ft])
      endif
      if !get(conf, 'use_default_user', 1)
        break
      endif
    elseif has_key(s:default_defs, ft)
      call add(q, s:default_defs[ft])
    endif
  endfor
  call extend(p, q)

  let defs = []
  for d in p
    if type(d) == type({}) && has_key(d, 'def')
      call extend(defs, d.def)
    elseif type(d) == type([])
      call extend(defs, d)
    endif
    unlet d
  endfor

  return defs
endfunction " }}}

let s:no_match = {}

function! s:is_nomatch(m) abort " {{{
  return a:m == s:no_match
endfunction " }}}

function! s:nmatch(conf) abort " {{{
  let col = col('.') - 1
  let line = getline('.')
  for i in range(len(a:conf.group))
    let d = a:conf.group[i]
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

function! s:vmatch(conf) abort " {{{
  let save_reg = [getreg('"'), getregtype('"')]

  try
    execute 'normal!' 'gvy'
    let pos1 = getpos('''[')
    let pos2 = getpos(''']')
    let text = getreg('"')
    if text =~# '\n'
      " unsupported
      return s:no_match
    endif

    for i in range(len(a:conf.group))
      let d = a:conf.group[i]
      let pattern = d.pattern
      if pattern[0] !=# '^'
        let pattern = '^' . pattern
      endif
      if pattern[len(pattern)-1] !=# '$'
        let pattern .= '$'
      endif
      if text =~# pattern
        let l1 = pos1[2]-1
        let l2 = pos2[2]
        let text = substitute(text, pattern, '\=submatch(1)', '')
        return {'start': l1, 'end': l2, 'len': l2-l1, 'index': i, 'conf': a:conf, 'text': text}
      endif
    endfor
    return s:no_match
  finally
    call setreg('"', save_reg[0], save_reg[1])
  endtry
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

function! s:replace(m, cnt) abort " {{{
  let c = a:cnt
  let idx = a:m.index + c
  if get(a:m.conf, 'cyclic', 1)
    let idx = s:mod(idx, len(a:m.conf.group))
  elseif idx < 0
    let idx = 0
  elseif idx >= len(a:m.conf.group)
    let idx = len(a:m.conf.group) - 1
  endif

  let d = a:m.conf.group[idx]
  if type(d.replace) == type(function('tr'))
    let str = d.replace(a:m.text, c, d)
  else
    let str = substitute(d.replace, '\\1', a:m.text, 'g')
  endif
  let line = getline('.')
  let pre = a:m.start < 1 ? '' : line[: a:m.start - 1]
  let line = pre . str . line[a:m.end :]
  call setline('.', line)
endfunction " }}}

function! s:group_normalize(d) abort " {{{
  if type(a:d) == type([])
    return {'group' : map(a:d, 's:group_normalize_elm(v:val)') }
  elseif type(a:d) == type({}) && has_key(a:d, 'group')
    let a:d.group = map(a:d.group, 's:group_normalize_elm(v:val)')
    return a:d
  else
    return {}
  endif
endfunction " }}}

function! s:group_normalize_elm(d) abort " {{{
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

function! s:do_nomatch(cnt) abort " {{{
  if !exists('g:clurin')
    return 0
  endif

  let d = g:clurin
  for ft in [&filetype, '-']
    if has_key(d, ft)
      if type(d[ft]) == type({}) && has_key(d[ft], 'nomatch') &&
            \ type(d[ft]['nomatch']) == type(function('tr'))
        return d[ft]['nomatch'](a:cnt)
      endif
    endif
  endfor
endfunction " }}}

function! clurin#pa(cnt, mode) abort " {{{
  silent! normal! zO

  if a:mode
    let Fmatch = function('s:vmatch')
  else
    let Fmatch = function('s:nmatch')
  endif

  let defs = s:getdefs()
  let mb = s:no_match
  for d in defs
    let dm = s:group_normalize(d)
    let m = Fmatch(dm)
    if s:cmp_match(mb, m) > 0
      let mb = m
    endif
    unlet d
  endfor

  if s:is_nomatch(mb)
    return s:do_nomatch(a:cnt)
  endif

"  let g:clurin#matchdef = mb " @debug
  call s:replace(mb, a:cnt)

  silent! call repeat#set(printf(":call clurin#pa(%d)\<CR>", a:cnt))
  return 1
endfunction " }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
