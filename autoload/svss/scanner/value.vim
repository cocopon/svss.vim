" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! svss#scanner#value#raw(raw_value)
	return a:raw_value
endfunction


function! svss#scanner#value#color(raw_value)
	let comps = svss#color#split(a:raw_value)
	return empty(comps)
				\ ? a:raw_value
				\ : svss#value#color#new('rgb', comps)
endfunction


function! svss#scanner#value#list(raw_value)
	let items = split(a:raw_value, ',')
	call map(items, 'svss#value#word#new(v:val)')
	return svss#value#list#new(items)
endfunction



let &cpo = s:save_cpo
unlet s:save_cpo
