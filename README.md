vim-clurin
=====================

# usage

```vim
nmap + <Plug>(clurin-next)
nmap - <Plug>(clurin-prev)
```

# customize

```vim
let g:clurin#config = {
\  '-': [[
\		{'pattern': '\(-\?\d\+\)', 'replace': function('g:CountUp')},
\   ], [
\		{'pattern': '\<true\>', 'replace': 'true'},
\		{'pattern': '\<false\>', 'replace': 'false'},
\   ], [
\      'on', 'off'
\   ]], 
\  'vim': [[
\		{'pattern': '''\(\k\+\)''', 'replace': '''\1'''},
\		{'pattern': '"\(\k\+\)"', 'replace': '"\1"'},
\   ]], 
\  'c' : [
\       [ '&&', '||' ],
\       [
\         {'pattern': '\(\k\+\)\.', 'replace': '\1.'},
\         {'pattern': '\(\k\+\)->', 'replace': '\1->'},
\   ]],
\}

function! g:CountUp(str, cnt, def) abort
  " a:str: matched_text
  " a:cnt: non zero.
  " a:def: definition
  return str2nr(a:str) + a:cnt
endfunction
```

# Similar work

- [switch.vim](https://github.com/AndrewRadev/switch.vim)
- [toggle.vim](http://www.vim.org/scripts/script.php?script_id=895)
- [cycle.vim](https://github.com/zef/vim-cycle)

