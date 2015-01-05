" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:method_names = [
			\ 	'evaluate',
			\ 	'name',
			\ 	'type',
			\ ]


function! svss#value#word#new(name) abort
	let word = {}
	let word.name_ = a:name

	call svss#util#class#setup_methods(
				\ word,
				\ 'svss#value#word',
				\ s:method_names)

	return word
endfunction


function! svss#value#word#type() abort dict
	return 'word'
endfunction


function! svss#value#word#name() abort dict
	return self.name_
endfunction


function! svss#value#word#evaluate(ruleset) abort dict
	return self.name_
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
