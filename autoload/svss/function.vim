" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:method_names = [
			\ 	'arguments',
			\ 	'evaluate',
			\ 	'name',
			\ 	'opt_arguments',
			\ 	'type',
			\ ]


function! svss#function#new(name, args, opt_args)
	let func = {}
	let func.name_ = a:name
	let func.args_ = a:args
	let func.opt_args_ = a:opt_args

	call svss#util#class#setup_methods(
				\ func,
				\ 'svss#function',
				\ s:method_names)

	return func
endfunction


" public {{{
function! svss#function#type() dict
	return 'function'
endfunction


function! svss#function#arguments() dict
	return self.args_
endfunction


function! svss#function#name() dict
	return self.name_
endfunction


function! svss#function#opt_arguments() dict
	return self.opt_args_
endfunction


function! svss#function#evaluate(ruleset) dict
	try
		let func_name = printf('svss#function#%s#execute',
					\ s:normalize_name(self.name_))
		let result = function(func_name)(a:ruleset, self)
		return result
	catch /:E117:/
		" E117: Unknown function
		throw printf('Function not found: %s',
					\ self.name_)
	endtry
endfunction
" }}}


" static {{{
function! svss#function#exists(name)
	try
		let func_name = printf('svss#function#%s#exists',
					\ s:normalize_name(a:name))
		let result = function(func_name)()
		return 1
	catch /:E117:/
		" E117: Unknown function
		return 0
	endtry
endfunction


function! svss#function#validate_total_arguments(func, expected)
	let actual = len(a:func.arguments())
	if actual != a:expected
		throw printf('Wrong number of arguments: %d for %d',
					\ actual, a:expected)
	endif
endfunction
" }}}


" private {{{
function! s:normalize_name(name)
	return substitute(a:name, '-', '_', 'g')
endfunction
" }}}


let &cpo = s:save_cpo
unlet s:save_cpo
