" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! svss#decompiler#value#string(string)
	let result = a:string.value()
	let result = substitute(result, '\', '\\', 'g')
	let result = substitute(result, "'", "\\'", 'g')
	return printf("'%s'", result)
endfunction


function! svss#decompiler#value#number(number)
	return string(a:number)
endfunction


function! svss#decompiler#value#color(color)
	return printf('%s(%s)',
				\ a:color.space(),
				\ join(a:color.components(), ', '))
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
