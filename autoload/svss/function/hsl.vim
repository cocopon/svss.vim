" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! svss#function#hsl#exists() abort
	return 1
endfunction


function! svss#function#hsl#execute(ruleset, func) abort
	call svss#function#validate_total_arguments(a:func, 3)
	let comps = map(copy(a:func.arguments()), 'v:val.evaluate(a:ruleset)')
	let rgb_comps = svss#color#hsl#to_rgb(comps)
	return svss#color#join(rgb_comps)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
