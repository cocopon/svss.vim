" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:method_names = [
			\ 	'type',
			\ 	'value',
			\ ]


function! svss#value#string#new(value) abort
	let str = {}
	let str.value_ = a:value

	call svss#util#class#setup_methods(
				\ str,
				\ 'svss#value#string',
				\ s:method_names)

	return str
endfunction


function! svss#value#string#type() abort
	return 'string'
endfunction


function! svss#value#string#value() abort dict
	return self.value_
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
