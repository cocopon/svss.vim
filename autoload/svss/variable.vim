" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:method_names = [
			\ 	'calculate',
			\ 	'name',
			\ 	'type',
			\ ]


function! svss#variable#new(name)
	let var = {}
	let var.name_ = a:name

	call svss#util#class#setup_methods(
				\ var,
				\ 'svss#variable',
				\ s:method_names)

	return var
endfunction


function! svss#variable#type()
	return 'variable'
endfunction


function! svss#variable#name() dict
	return self.name_
endfunction


function! svss#variable#calculate(ruleset) dict
	let value = a:ruleset.variable_value(self.name_)
	" TODO: Detect circular reference
	return value.calculate(a:ruleset)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
