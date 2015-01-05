" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! svss#value#validate_type(value, expected) abort
	let actual = a:value.type()
	if actual !=# a:expected
		throw printf('Unmatched type: %s for %s',
					\ actual, a:expected)
	endif
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
