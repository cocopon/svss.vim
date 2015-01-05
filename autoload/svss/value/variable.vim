" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:method_names = [
			\ 	'evaluate',
			\ 	'name',
			\ 	'type',
			\ ]


function! svss#value#variable#new(name) abort
	let var = {}
	let var.name_ = a:name

	call svss#util#class#setup_methods(
				\ var,
				\ 'svss#value#variable',
				\ s:method_names)

	return var
endfunction


function! svss#value#variable#type() abort
	return 'variable'
endfunction


function! svss#value#variable#name() abort dict
	return self.name_
endfunction


function! svss#value#variable#evaluate(ruleset) abort dict
	let value = a:ruleset.variable_value(self.name_)
	" TODO: Detect circular reference
	return value.evaluate(a:ruleset)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
