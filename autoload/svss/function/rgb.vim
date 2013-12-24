" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! svss#function#rgb#exists()
	return 1
endfunction


function! svss#function#rgb#execute(ruleset, func)
	call svss#function#validate_total_arguments(a:func, 3)
	return svss#color#join(a:func.arguments())
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
