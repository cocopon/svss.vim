" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! svss#color#split(hex) abort
	let matches = matchlist(a:hex, '^#\(\x\{2}\)\(\x\{2}\)\(\x\{2}\)$')
	return map(matches[1:3], 'str2nr(v:val, 16)')
endfunction


function! svss#color#join(comps) abort
	let comps = map(copy(a:comps), 'float2nr(v:val)')
	let comps = map(comps, 'svss#util#bound(v:val, 0, 255)')
	let comps = map(comps, 'printf("%02x", v:val)')
	return '#' . join(comps, '')
endfunction


function! svss#color#exists_space(space) abort
	try
		let name = printf('svss#color#%s#to_rgb', a:space)
		let result = function(name)([])
		return 1
	catch /:E117:/
		" E117: Unknown function
		return 0
	endtry
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
