" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:method_names = [
			\ 	'calculate',
			\ 	'type',
			\ 	'value',
			\ ]


function! svss#number#new(value)
	let num = {}
	let num.value_ = a:value

	call svss#util#class#setup_methods(
				\ num,
				\ 'svss#number',
				\ s:method_names)

	return num
endfunction


function! svss#number#type()
	return 'number'
endfunction


function! svss#number#value() dict
	return self.value_
endfunction


function! svss#number#calculate(ruleset) dict
	let value = str2float(self.value_)

	if self.value_[len(self.value_) - 1] == '%'
		let value = value * 0.01
	endif

	return value
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
