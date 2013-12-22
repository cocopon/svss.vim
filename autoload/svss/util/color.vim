" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! svss#util#color#split(hex)
	let matches = matchlist(a:hex, '^#\(\x\{2}\)\(\x\{2}\)\(\x\{2}\)$')
	return map(matches[1:3], 'str2nr(v:val, 16)')
endfunction


function! svss#util#color#join(comps)
	let hex = map(a:comps, 'printf("%02x", float2nr(v:val))')
	return '#' . join(hex, '')
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
