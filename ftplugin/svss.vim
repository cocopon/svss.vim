" Author:  cocopon <cocopon@me.com>
" License: MIT License


if exists('b:did_ftplugin')
	finish
endif
let b:did_ftplugin = 1


let s:cpo_save = &cpo
set cpo&vim


augroup svss
	autocmd!
	autocmd BufWritePost <buffer> call svss#bufwrite()
augroup END
let b:undo_ftplugin = 'setl cms< fo<'
			\ . ' | au! svss'

setlocal commentstring=//\ %s
setlocal formatoptions-=t formatoptions+=cloqr


let &cpo = s:cpo_save
unlet s:cpo_save
