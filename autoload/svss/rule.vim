" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:method_names = [
			\ 	'declarations',
			\ 	'selector',
			\ ]


function! svss#rule#new(selector, declarations)
	let rule = {}
	let rule.selector_ = a:selector
	let rule.declarations_ = a:declarations

	call svss#util#class#setup_methods(
				\ rule,
				\ 'svss#rule',
				\ s:method_names)

	return rule
endfunction


function! svss#rule#selector() dict
	return self.selector_
endfunction


function! svss#rule#declarations() dict
	return self.declarations_
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
