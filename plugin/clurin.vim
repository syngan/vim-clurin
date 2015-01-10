if exists("g:loaded_clurin")
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

command! -count=1 -bang ClurinNext :call clurin#pa(v:count1, <bang>0)
command! -count=1 -bang ClurinPrev :call clurin#pa(v:count1, <bang>1)

nnoremap <Plug>(clurin-next) :ClurinNext<CR>
nnoremap <Plug>(clurin-prev) :ClurinPrev<CR>

let g:loaded_clurin = 1

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
