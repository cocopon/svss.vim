" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:method_names = [
			\ 	'type',
			\ 	'value',
			\ ]


function! svss#string#new(value)
	let str = {}
	let str.value_ = a:value

	call svss#util#class#setup_methods(
				\ str,
				\ 'svss#string',
				\ s:method_names)

	return str
endfunction


function! svss#string#type()
	return 'string'
endfunction


function! svss#string#value() dict
	return self.value_
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
