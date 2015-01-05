" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! svss#decompiler#value#string(string) abort
	let result = a:string.value()
	let result = substitute(result, '\', '\\', 'g')
	let result = substitute(result, "'", "\\'", 'g')
	return printf("'%s'", result)
endfunction


function! svss#decompiler#value#number(number) abort
	return string(a:number)
endfunction


function! svss#decompiler#value#color(color) abort
	return printf('%s(%s)',
				\ a:color.space(),
				\ join(a:color.components(), ', '))
endfunction


function! svss#decompiler#value#word(word) abort
	return a:word.name()
endfunction


function! svss#decompiler#value#list(list) abort
	let items = map(copy(a:list.items()), 'v:val.name()')
	return join(items, ', ')
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
