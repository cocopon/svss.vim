" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:method_names = [
			\ 	'declarations',
			\ 	'selectors',
			\ ]


function! svss#rule#new(selectors, declarations) abort
	let rule = {}
	let rule.selectors_ = a:selectors
	let rule.declarations_ = a:declarations

	call svss#util#class#setup_methods(
				\ rule,
				\ 'svss#rule',
				\ s:method_names)

	return rule
endfunction


function! svss#rule#selectors() abort dict
	return self.selectors_
endfunction


function! svss#rule#declarations() abort dict
	return self.declarations_
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
