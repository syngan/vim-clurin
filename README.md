vim-clurin
=====================

[![Build Status](https://travis-ci.org/syngan/vim-clurin.svg?branch=master)](https://travis-ci.org/syngan/vim-clurin)

# usage

```vim
nmap + <Plug>(clurin-next)
nmap - <Plug>(clurin-prev)
vmap + <Plug>(clurin-next)
vmap - <Plug>(clurin-prev)
```

# customize

```
g:clurin: Dictionary of Dictionary. key: - or 'filetype'

	def			(List of GROUP, required)
	use_default		(Bool, 1)
	use_default_user	(Bool, 1)
	nomatch  (Funcref({cnt}), none)
	jump     (Bool, 0)  0: under the cursor, otherwise: after the cursor

GROUP:: Dictionary or group
	cyclic			(Bool, 1)
	group			(List of Dictionary or Strings)
		Dictionary:
			pattern		(String)
			replace		(String or Funcref({str},{cnt},{def}))
				{str}: matched text
				{cnt}: count
				{def}: normalized def.
			String {s}
				string. NOTE: cannot use regexp .
				 -> {'pattern': '\<\({s}\)\>', 'replace' '{s}'} ({s}='^\k\+$') or
				    {'pattern': '\({s}\)', 'replace' '{s}'}
```

## example

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

let g:clurin = {
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


## receipt

ruby string: 'string' -> "string" -> :string
```vim
\     [
\       {'pattern': '''\(\k\+\)''', 'replace': '''\1'''},
\       {'pattern': '"\(\k\+\)"', 'replace': '"\1"'},
\       {'pattern': ':\(\k\+\)"', 'replace': ':\1'},
\     ]
```

closure string: 'string -> "string" -> :string
```vim
\     [
\       {'pattern': '''\(\k\+\)', 'replace': '''\1'},
\       {'pattern': '"\(\k\+\)"', 'replace': '"\1"'},
\       {'pattern': ':\(\k\+\)"', 'replace': ':\1'},
\     ]
```

vim dictionary: ['key'] -> ["key"] -> .key
```vim
\     [
\       {'pattern': '\[''\(\k\+\)''\]', 'replace': '[''\1'']'},
\       {'pattern': '\["\(\k\+\)"\]',   'replace': '["\1"]'},
\       {'pattern': '\.\(\k\+\)',       'replace': '.\1'},
\     ]
```


# Similar work

- [switch.vim](https://github.com/AndrewRadev/switch.vim)
- [toggle.vim](http://www.vim.org/scripts/script.php?script_id=895)
- [cycle.vim](https://github.com/zef/vim-cycle)

