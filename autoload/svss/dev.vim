" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! svss#dev#inspect()
	let synid = synID(line('.'), col('.'), 1)
	let result = synIDattr(synid, 'name')

	let original = synIDtrans(synid)
	if synid != original
		let result .= ' -> ' . synIDattr(original, 'name')
	endif

	echo result
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
