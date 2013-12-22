" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:method_names = [
			\ 	'type',
			\ 	'name',
			\ 	'value',
			\ ]


function! svss#definition#new(name, value)
	let def = {}
	let def.name_ = a:name
	let def.value_ = a:value

	call svss#util#class#setup_methods(
				\ def,
				\ 'svss#definition',
				\ s:method_names)

	return def
endfunction


function! svss#definition#type() dict
	return 'definition'
endfunction


function! svss#definition#name() dict
	return self.name_
endfunction


function! svss#definition#value() dict
	return self.value_
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
