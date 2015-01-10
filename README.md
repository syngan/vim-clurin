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
\		{'pattern': '\<true\>', 'replace': 'true'},
\		{'pattern': '\<false\>', 'replace': 'false'},
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
```

# Similar work

- [switch.vim](https://github.com/AndrewRadev/switch.vim)
- [toggle.vim](http://www.vim.org/scripts/script.php?script_id=895)
- [cycle.vim](https://github.com/zef/vim-cycle)

