" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:method_names = [
			\ 	'evaluate',
			\ 	'type',
			\ 	'value',
			\ ]


function! svss#value#number#new(value) abort
	let num = {}
	let num.value_ = a:value

	call svss#util#class#setup_methods(
				\ num,
				\ 'svss#value#number',
				\ s:method_names)

	return num
endfunction


function! svss#value#number#type() abort
	return 'number'
endfunction


function! svss#value#number#value() abort dict
	return self.value_
endfunction


function! svss#value#number#evaluate(ruleset) abort dict
	let value = str2float(self.value_)

	if self.value_[len(self.value_) - 1] ==? '%'
		let value = value * 0.01
	endif

	return value
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
