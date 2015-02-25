vim-clurin
=====================

# usage

```vim
nmap + <Plug>(clurin-next)
nmap - <Plug>(clurin-prev)
```

# customize

```vim
function! g:CountUp(str, cnt, def) abort
  " a:str: matched_text
  " a:cnt: non zero.
  " a:def: definition
  return str2nr(a:str) + a:cnt
endfunction

function! g:CtrlAX(cnt) abort
	if a:cnt >= 0
		execute 'normal!' a:cnt . "\<C-A>"
	else
		execute 'normal!' (-a:cnt) . "\<C-X>"
	endif
endfunction

let g:clurin#config = {
\ '-': { 'def': [[
\       {'pattern': '\(-\?\d\+\)', 'replace': function('g:CountUp')},
\     ], [
\       {'pattern': '\<true\>', 'replace': 'true'},
\       {'pattern': '\<false\>', 'replace': 'false'},
\     ], [
\       'on', 'off'
\     ]]},
\ 'vim': {'def': [[
\       {'pattern': '''\(\k\+\)''', 'replace': '''\1'''},
\       {'pattern': '"\(\k\+\)"', 'replace': '"\1"'},
\     ]]},
\ 'c' : {'def': [
\     [ '&&', '||' ],
\     [
\       {'pattern': '\(\k\+\)\.', 'replace': '\1.'},
\       {'pattern': '\(\k\+\)->', 'replace': '\1->'},
\     ]], 'nomatch': function('g:CtrlAX')},
\}


```

# Similar work

- [switch.vim](https://github.com/AndrewRadev/switch.vim)
- [toggle.vim](http://www.vim.org/scripts/script.php?script_id=895)
- [cycle.vim](https://github.com/zef/vim-cycle)

