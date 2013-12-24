" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! svss#util#bound(value, min, max)
	let result = (a:value < a:min) ? a:min : a:value
	return (result > a:max) ? a:max : a:value
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
