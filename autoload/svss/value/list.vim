" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:method_names = [
			\ 	'evaluate',
			\ 	'items',
			\ 	'type',
			\ ]


function! svss#value#list#new(items) abort
	let list = {}
	let list.items_ = a:items

	call svss#util#class#setup_methods(
				\ list,
				\ 'svss#value#list',
				\ s:method_names)

	return list
endfunction


function! svss#value#list#type() abort dict
	return 'list'
endfunction


function! svss#value#list#items() abort dict
	return self.items_
endfunction


function! svss#value#list#evaluate(ruleset) abort dict
	let items = map(copy(self.items_), 'v:val.evaluate(a:ruleset)')
	return join(items, ',')
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
