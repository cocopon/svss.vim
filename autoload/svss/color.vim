" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! svss#color#exists_space(space)
	try
		let name = printf('svss#color#%s#to_rgb', a:space)
		let result = function(name)([])
		return 1
	catch /:E117:/
		" E117: Unknown function
		return 0
	endtry
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
