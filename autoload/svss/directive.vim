" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:method_names = [
			\ 	'name',
			\ 	'argument',
			\ 	'arguments',
			\ ]


function! svss#directive#new(name, arguments) abort
	let directive = {}
	let directive.name_ = a:name
	let directive.args_ = a:arguments

	call svss#util#class#setup_methods(
				\ directive,
				\ 'svss#directive',
				\ s:method_names)

	return directive
endfunction


function! svss#directive#name() abort dict
	return self.name_
endfunction


function! svss#directive#argument(index) abort dict
	return self.args_[a:index]
endfunction


function! svss#directive#arguments() abort dict
	return self.args_
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
