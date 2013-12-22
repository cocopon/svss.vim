" Author:  cocopon <cocopon@me.com>
" License: MIT License


if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1


let s:cpo_save = &cpo
set cpo&vim


augroup svss
  autocmd!
	autocmd BufWrite <buffer> call svss#bufwrite()
augroup END
let b:undo_ftplugin = 'au! svss'


let &cpo = s:cpo_save
unlet s:cpo_save
