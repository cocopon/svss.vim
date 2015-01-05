" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:method_names = [
			\ 	'property',
			\ 	'value',
			\ ]


function! svss#declaration#new(property, value) abort
	let declaration = {}
	let declaration.property_ = a:property
	let declaration.value_ = a:value

	call svss#util#class#setup_methods(
				\ declaration,
				\ 'svss#declaration',
				\ s:method_names)

	return declaration
endfunction


function! svss#declaration#property() abort dict
	return self.property_
endfunction


function! svss#declaration#value() abort dict
	return self.value_
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
